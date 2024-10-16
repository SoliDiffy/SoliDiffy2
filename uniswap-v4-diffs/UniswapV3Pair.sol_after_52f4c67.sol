pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';
import '@uniswap/lib/contracts/libraries/Babylonian.sol';

import './interfaces/IUniswapV3Pair.sol';
import './libraries/Math.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV3Factory.sol';
import './interfaces/IUniswapV3Callee.sol';
import './libraries/FixedPointExtra.sol';

contract UniswapV3Pair is IUniswapV3Pair {
    using SafeMath for uint;
    using FixedPoint for FixedPoint.uq112x112;
    using FixedPointExtra for FixedPoint.uq112x112;
    using FixedPoint for FixedPoint.uq144x112;

    uint112 public constant override MINIMUM_LIQUIDITY = uint112(10**3);

    address public immutable override factory;
    address public immutable override token0;
    address public immutable override token1;

    uint112 public lpFee; // in bps

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public override price0CumulativeLast;
    uint public override price1CumulativeLast;
    uint public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint112 private virtualSupply;  // current virtual supply;
    uint64 private timeInitialized; // timestamp when pool was initialized

    uint16 public currentTick; // the current tick for the token0 price (rounded down)

    uint private unlocked = 1;
    
    struct TickInfo {
        uint32 secondsGrowthOutside;         // measures number of seconds spent while pool was on other side of this tick (from the current price)
        FixedPoint.uq112x112 kGrowthOutside; // measures growth due to fees while pool was on the other side of this tick (from the current price)
    }

    mapping (uint16 => TickInfo) tickInfos;  // mapping from tick indexes to information about that tick
    mapping (uint16 => int112) deltas;       // mapping from tick indexes to amount of token0 kicked in or out when tick is crossed

    struct Position {
        uint112 token0Owed;
        uint112 token1Owed;
        uint112 liquidity; // virtual liquidity shares, normalized to this range
    }

    // TODO: is this really the best way to map (address, uint16, uint16)
    // user address, lower tick, upper tick
    mapping (address => mapping (uint16 => mapping (uint16 => Position))) positions;


    modifier lock() {
        require(unlocked == 1, 'UniswapV3: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    // returns sqrt(x*y)/shares
    function getInvariant() public view returns (FixedPoint.uq112x112 memory k) {
        uint112 rootXY = uint112(Babylonian.sqrt(uint256(reserve0) * uint256(reserve1)));
        return FixedPoint.encode(rootXY).div(virtualSupply);
    }

    function getGrowthAbove(uint16 tickIndex, uint16 _currentTick, FixedPoint.uq112x112 memory _k) public view returns (FixedPoint.uq112x112 memory) {
        TickInfo memory _tickInfo = tickInfos[tickIndex];
        if (_tickInfo.secondsGrowthOutside == 0) {
            return FixedPoint.encode(1);
        }
        FixedPoint.uq112x112 memory kGrowthOutside = tickInfos[tickIndex].kGrowthOutside;
        if (_currentTick >= tickIndex) {
            // this range is currently active
            return _k.uqdiv112(kGrowthOutside);
        } else {
            // this range is currently inactive
            return kGrowthOutside;
        }
    }

    function getGrowthBelow(uint16 tickIndex, uint16 _currentTick, FixedPoint.uq112x112 memory _k) public view returns (FixedPoint.uq112x112 memory) {
        FixedPoint.uq112x112 memory kGrowthOutside = tickInfos[tickIndex].kGrowthOutside;
        if (_currentTick < tickIndex) {
            // this range is currently active
            return _k.uqdiv112(kGrowthOutside);
        } else {
            // this range is currently inactive
            return kGrowthOutside;
        }
    }

    // gets the growth in K for within a particular range
    function getGrowthInside(uint16 _lowerTick, uint16 _upperTick) public view returns (FixedPoint.uq112x112 memory growth) {
        // TODO: simpler or more precise way to compute this?
        FixedPoint.uq112x112 memory _k = getInvariant();

        uint16 _currentTick = currentTick;
        FixedPoint.uq112x112 memory growthAbove = getGrowthAbove(_upperTick, _currentTick, _k);
        FixedPoint.uq112x112 memory growthBelow = getGrowthBelow(_lowerTick, _currentTick, _k);
        return growthAbove.uqmul112(growthBelow).reciprocal().uqmul112(_k);
    }

    function normalizeToRange(uint112 liquidity, uint16 lowerTick, uint16 upperTick) internal view returns (uint112) {
        FixedPoint.uq112x112 memory kGrowthRange = getGrowthInside(lowerTick, upperTick);
        return kGrowthRange.mul112(liquidity).decode();
    }

    function getReserves() public override view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    constructor(address token0_, address token1_) public {
        factory = msg.sender;
        token0 = token0_;
        token1 = token1_;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint112 _reserve0, uint112 _reserve1) private {
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // + overflow is desired
            price0CumulativeLast += FixedPoint.encode(_reserve1).div(_reserve0).mul(timeElapsed).decode144();
            price1CumulativeLast += FixedPoint.encode(_reserve0).div(_reserve1).mul(timeElapsed).decode144();
        }
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = blockTimestamp;
    }

    // TODO: 
    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV3Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        uint112 _virtualSupply = virtualSupply;
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Babylonian.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Babylonian.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = uint(_virtualSupply).mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint112 liquidity = uint112(numerator / denominator);
                    if (liquidity > 0) {
                        positions[feeTo][0][0].liquidity += liquidity;
                        virtualSupply = _virtualSupply + liquidity;
                    }
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function getBalancesAtPrice(uint112 sqrtXY, FixedPoint.uq112x112 memory price) internal pure returns (uint112 balance0, uint112 balance1) {
        balance0 = price.reciprocal().sqrt().mul112(sqrtXY).decode();
        balance1 = price.mul112(balance0).decode();
    }

    function getBalancesAtTick(uint112 sqrtXY, uint16 tick) internal pure returns (uint112 balance0, uint112 balance1) {
        if (tick == 0) {
            return (0, 0);
        }
        FixedPoint.uq112x112 memory price = getTickPrice(tick);
        return getBalancesAtPrice(sqrtXY, price);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function initialAdd(uint112 amount0, uint112 amount1, uint16 startingTick) external override lock returns (uint112 liquidity) {
        require(virtualSupply == 0, "UniswapV3: ALREADY_INITIALIZED");
        FixedPoint.uq112x112 memory price = FixedPoint.encode(amount1).div(amount0);
        require(price._x > getTickPrice(startingTick)._x && price._x < getTickPrice(startingTick + 1)._x);
        bool feeOn = _mintFee(0, 0);
        liquidity = uint112(Babylonian.sqrt(uint256(amount0).mul(uint256(amount1))).sub(uint(MINIMUM_LIQUIDITY)));
        positions[address(0)][0][0].liquidity = MINIMUM_LIQUIDITY;
        positions[msg.sender][0][0] = Position({
            token0Owed: 0,
            token1Owed: 0,
            liquidity: liquidity
        });
        virtualSupply = liquidity + MINIMUM_LIQUIDITY;
        require(liquidity > 0, 'UniswapV3: INSUFFICIENT_LIQUIDITY_MINTED');
        uint112 _reserve0 = amount0;
        uint112 _reserve1 = amount1;
        currentTick = startingTick;
        _update(_reserve0, _reserve1);
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, msg.sender, address(this), amount1);
        if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
        emit Add(address(0), MINIMUM_LIQUIDITY, 0, 0);
        emit Add(msg.sender, liquidity, 0, 0);
    }

    // // this low-level function should be called from a contract which performs important safety checks
    // function burn(address to, uint liquidity) external override lock returns (uint amount0, uint amount1) {
    //     (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
    //     address _token0 = token0;                                // gas savings
    //     address _token1 = token1;                                // gas savings

    //     bool feeOn = _mintFee(_reserve0, _reserve1);
    //     uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
    //     uint amount0 = liquidity.mul(uint(_reserve0)) / _totalSupply;
    //     uint amount1 = liquidity.mul(uint(_reserve1)) / _totalSupply;
    //     require(amount0 > 0 && amount1 > 0, 'UniswapV3: INSUFFICIENT_LIQUIDITY_BURNED');
    //     _burn(msg.sender, liquidity);
    //     _reserve0 -= amount0;
    //     _reserve1 -= amount1;
    //     _update(_reserve0, _reserve1);
    //     TransferHelper.safeTransfer(_token0, to, amount0);
    //     TransferHelper.safeTransfer(_token1, to, amount1);
    //     if (feeOn) kLast = uint(_reserve0).mul(_reserve1); // reserve0 and reserve1 are up-to-date
    //     emit Burn(msg.sender, amount0, amount1, to);
    // }

    // add a specified amount of fully levered liquidity to a specified range
    function add(uint112 liquidity, uint16 lowerTick, uint16 upperTick) external override lock {
        require(liquidity > 0, 'UniswapV3: INSUFFICIENT_LIQUIDITY_MINTED');
        require(lowerTick < upperTick || upperTick == 0, "UniswapV3: BAD_TICKS");
        Position memory _position = positions[msg.sender][lowerTick][upperTick];
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint112 _virtualSupply = virtualSupply; // gas savings, must be defined here since virtualSupply can update in _mintFee
        require(_virtualSupply > 0, 'UniswapV3: NOT_INITIALIZED');

        // TODO: oh my god, the scope issues        

        // normalized values to the range
        uint112 adjustedLiquidity = normalizeToRange(liquidity, lowerTick, upperTick);

        // calculate how much the new shares are worth at lower ticks and upper ticks
        (uint112 lowerToken0Balance, uint112 lowerToken1Balance) = getBalancesAtTick(adjustedLiquidity, lowerTick);
        (uint112 upperToken0Balance, uint112 upperToken1Balance) = getBalancesAtTick(adjustedLiquidity, upperTick);
        uint112 amount0;
        uint112 amount1;

        if (currentTick < lowerTick) {
            amount0 = 0;
            amount1 = lowerToken1Balance - upperToken1Balance;
            deltas[lowerTick] += int112(lowerToken0Balance);
            if (upperTick != 0) {
                deltas[upperTick] -= int112(upperToken0Balance);
            }
        } else if (currentTick < upperTick || upperTick == 0) {
            FixedPoint.uq112x112 memory currentPrice = FixedPoint.encode(reserve1).div(reserve0);
            (uint112 virtualAmount0, uint112 virtualAmount1) = getBalancesAtPrice(adjustedLiquidity, currentPrice);
            amount0 = virtualAmount0 - lowerToken0Balance;
            amount1 = virtualAmount1 - upperToken1Balance;
            _reserve0 += virtualAmount0;
            _reserve1 += virtualAmount1;
            // yet ANOTHER adjusted liquidity amount (this one is equivalent to scaling up liquidity by _k)
            virtualSupply = _virtualSupply + normalizeToRange(liquidity, 0, 0);
            if (lowerTick != 0) {
                deltas[lowerTick] -= int112(lowerToken0Balance);
            }
            if (upperTick != 0) {
                deltas[upperTick] -= int112(upperToken0Balance);
            }
        } else {
            amount0 = upperToken1Balance - lowerToken1Balance;
            amount1 = 0;
            deltas[upperTick] += int112(upperToken1Balance);
            if (lowerTick != 0) {
                deltas[lowerTick] -= int112(lowerToken0Balance);
            }
        }
        positions[msg.sender][lowerTick][upperTick] = Position({
            token0Owed: _position.token0Owed + lowerToken0Balance,
            token1Owed: _position.token1Owed + upperToken1Balance,
            liquidity: _position.liquidity + liquidity
        });
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, msg.sender, address(this), amount1);
        _update(_reserve0, _reserve1);
        if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
        emit Add(msg.sender, liquidity, lowerTick, upperTick);
    }

    // reinvest accumulated fees (which are unlevered) in levered liquidity
    // technically this doesn't do anything that can't be done with remove() and add()
    // but this gives significant gas savings (at least four transfers) on the common task of pinging to reinvest fees
    function sync(uint16 lowerTick, uint16 upperTick) external override lock {
        Position memory _position = positions[msg.sender][lowerTick][upperTick];

        
    }

    // remove some liquidity from a given range, paying back as many tokens as needed, and sending the rest to the user
    function remove(uint112 liquidity, uint16 lowerTick, uint16 upperTick) external override lock {
        // TODO
        emit Remove(msg.sender, liquidity, lowerTick, upperTick);
    }

    function getTradeToRatio(uint112 y0, uint112 x0, FixedPoint.uq112x112 memory price, uint112 _lpFee) internal pure returns (uint112) {
        // todo: clean up this monstrosity, which won't even compile because the stack is too deep
        // simplification of https://www.wolframalpha.com/input/?i=solve+%28x0+-+x0*%281-g%29*y%2F%28y0+%2B+%281-g%29*y%29%29%2F%28y0+%2B+y%29+%3D+p+for+y
        // uint112 numerator = price.sqrt().mul112(uint112(Babylonian.sqrt(y0))).mul112(uint112(Babylonian.sqrt(price.mul112(y0).mul112(lpFee).mul112(lpFee).div(10000).add(price.mul112(4 * x0).mul112(10000 - lpFee)).decode()))).decode();
        // uint112 denominator = price.mul112(10000 - lpFee).div(10000).mul112(2).decode();
        return uint112(1);
    }

    // TODO: implement swap1for0, or integra4rte it into this
    function swap0for1(uint amountIn, address to, bytes calldata data) external lock {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        uint16 _currentTick = currentTick;
        uint112 _virtualSupply = virtualSupply;

        uint112 totalAmountOut = 0;

        uint112 amountInLeft = uint112(amountIn);
        uint112 amountOut = 0;
        uint112 _lpFee = lpFee;

        while (amountInLeft > 0) {
            FixedPoint.uq112x112 memory price = getTickPrice(_currentTick);

            // compute how much would need to be traded to get to the next tick down
            uint112 maxAmount = getTradeToRatio(_reserve0, _reserve1, price, _lpFee);
        
            uint112 amountToTrade = (amountInLeft > maxAmount) ? maxAmount : amountInLeft;

            // execute the sell of amountToTrade
            uint112 adjustedAmountToTrade = amountToTrade * (10000 - _lpFee) / 10000;
            uint112 amountOutStep = (adjustedAmountToTrade * _reserve1) / (_reserve0 + adjustedAmountToTrade);

            amountOut += amountOutStep;
            _reserve0 -= amountOutStep;
            // TODO: handle overflow?
            _reserve1 += amountToTrade;

            amountInLeft = amountInLeft - amountToTrade;
            if (amountInLeft == 0) { // shift past the tick
                FixedPoint.uq112x112 memory k = FixedPoint.encode(uint112(Babylonian.sqrt(uint(_reserve0) * uint(_reserve1)))).div(virtualSupply);
                TickInfo memory _oldTickInfo = tickInfos[_currentTick];
                FixedPoint.uq112x112 memory _oldKGrowthOutside = _oldTickInfo.secondsGrowthOutside != 0 ? _oldTickInfo.kGrowthOutside : FixedPoint.encode(uint112(1));
                // get delta of token0
                int112 _delta = deltas[_currentTick];
                // TODO: try to mint protocol fee in some way that batches the calls and updates across multiple ticks
                bool feeOn = _mintFee(_reserve0, _reserve1);
                // kick in/out liquidity
                // TODO: fix this all to work with int112 delta!
                if (_delta > 0) {
                    _reserve0 += uint112(uint112(_delta));
                    _reserve1 += price.mul112(uint112(_delta)).decode();
                    uint112 shareDelta = uint112((uint(_virtualSupply) * uint112(_delta)) / uint(_reserve0));
                    _virtualSupply += shareDelta;
                } else {
                    _reserve0 -= uint112(-1 * _delta);
                    _reserve1 -= price.mul112(uint112(-1 * _delta)).decode();
                    uint112 shareDelta = uint112((uint(_virtualSupply) * uint(-1 * _delta)) / uint(_reserve0));
                    _virtualSupply -= shareDelta;
                }
                // update the delta
                deltas[_currentTick] = -1 * _delta;
                // update tick info
                tickInfos[_currentTick] = TickInfo({
                    // TODO: the overflow trick may not work here... we may need to switch to uint40 for timestamp
                    secondsGrowthOutside: uint32(block.timestamp % 2**32) - uint32(timeInitialized) - _oldTickInfo.secondsGrowthOutside,
                    kGrowthOutside: k.uqdiv112(_oldKGrowthOutside)
                });
                emit Shift(_currentTick);
                if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
                _currentTick -= 1;
            }
        }
        currentTick = _currentTick;
        TransferHelper.safeTransfer(token1, msg.sender, amountOut);
        if (data.length > 0) IUniswapV3Callee(to).uniswapV3Call(msg.sender, 0, totalAmountOut, data);
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountIn);
        _update(_reserve0, _reserve1);
        emit Swap(msg.sender, false, amountIn, amountOut, to);
    }

    function getTickPrice(uint16 index) public pure returns (FixedPoint.uq112x112 memory) {
        // returns a UQ112x112 representing the price of token0 in terms of token1, at the tick with that index

        int signedIndex = int(index) - 2**15;
        if (signedIndex == 0) {
            return FixedPoint.encode(1);
        }

        uint16 absIndex = signedIndex > 0 ? uint16(signedIndex) : uint16(-1 * signedIndex);

        // compute 1.01^abs(index)
        // TODO: improve and fix this math, which is currently totally wrong
        // adapted from https://ethereum.stackexchange.com/questions/10425/is-there-any-efficient-way-to-compute-the-exponentiation-of-a-fraction-and-an-in
        FixedPoint.uq112x112 memory price = FixedPoint.encode(0);
        FixedPoint.uq112x112 memory N = FixedPoint.encode(1);
        uint112 B = 1;
        uint112 q = 100;
        uint precision = 50;
        for (uint i = 0; i < precision; ++i){
            price.add(N.div(B).div(q));
            N  = N.mul112(uint112(absIndex - uint112(i)));
            B = B * uint112(i+1);
            q = q * 100;
        }

        if (signedIndex < 0) {
            return price.reciprocal();
        }

        return price;
    }
}