// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/lib/contracts/libraries/FullMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SignedSafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import './libraries/SafeCast.sol';
import './libraries/MixedSafeMath.sol';
import './libraries/SqrtPriceMath.sol';
import './libraries/SwapMath.sol';
import './libraries/SqrtTickMath.sol';

import './interfaces/IUniswapV3Pair.sol';
import './interfaces/IUniswapV3PairDeployer.sol';
import './interfaces/IUniswapV3Factory.sol';
import './interfaces/IUniswapV3MintCallback.sol';
import './interfaces/IUniswapV3SwapCallback.sol';
import './libraries/SpacedTickBitmap.sol';
import './libraries/FixedPoint128.sol';
import './libraries/Tick.sol';

contract UniswapV3Pair is IUniswapV3Pair {
    using SafeMath for uint128;
    using SafeMath for uint256;
    using SignedSafeMath for int128;
    using SignedSafeMath for int256;
    using SafeCast for int256;
    using SafeCast for uint256;
    using MixedSafeMath for uint128;
    using FixedPoint128 for FixedPoint128.uq128x128;
    using SpacedTickBitmap for mapping(int16 => uint256);
    using Tick for mapping(int24 => Tick.Info);

    uint8 private constant PRICE_BIT = 0x10;
    uint8 private constant UNLOCKED_BIT = 0x01;

    // if we constrain the gross liquidity associated to a single tick, then we can guarantee that the total
    // liquidityCurrent never exceeds uint128
    // the max liquidity for a single tick fee vote is then:
    //   floor(type(uint128).max / (number of ticks))
    //     = (2n ** 128n - 1n) / (2n ** 24n)
    // this is about 104 bits
    uint128 private constant MAX_LIQUIDITY_GROSS_PER_TICK = 20282409603651670423947251286015;

    address public immutable override factory;
    address public immutable override token0;
    address public immutable override token1;
    uint24 public immutable override fee;

    // how far apart initialized ticks must be
    // e.g. a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e. ..., -6, -3, 0, 3, 6, ...
    // int24 to avoid casting even though it's always positive
    int24 public immutable override tickSpacing;

    // the minimum and maximum tick for the pair
    // always a multiple of tickSpacing
    int24 public immutable override MIN_TICK;
    int24 public immutable override MAX_TICK;

    struct Slot0 {
        // the current price
        FixedPoint96.uq64x96 sqrtPriceCurrent;
        // the last block timestamp where the tick accumulator was updated
        uint32 blockTimestampLast;
        // the tick accumulator, i.e. tick * time elapsed since the pair was first initialized
        int56 tickCumulativeLast;
        // whether the pair is locked for swapping
        // packed with a boolean representing whether the price is at the lower bounds of the
        // tick boundary but the tick transition has already happened
        uint8 unlockedAndPriceBit;
    }

    Slot0 public override slot0;

    struct Slot1 {
        // current in-range liquidity
        uint128 liquidityCurrent;
    }

    Slot1 public override slot1;

    address public override feeTo;

    // see TickBitmap.sol
    mapping(int16 => uint256) public override tickBitmap;

    // fee growth per unit of liquidity
    FixedPoint128.uq128x128 public override feeGrowthGlobal0;
    FixedPoint128.uq128x128 public override feeGrowthGlobal1;

    // accumulated protocol fees
    uint256 public override feeToFees0;
    uint256 public override feeToFees1;

    mapping(int24 => Tick.Info) public tickInfos;

    struct Position {
        uint128 liquidity;
        // fee growth per unit of liquidity as of the last modification
        FixedPoint128.uq128x128 feeGrowthInside0Last;
        FixedPoint128.uq128x128 feeGrowthInside1Last;
        // the fees owed to the position owner in token0/token1
        uint256 feesOwed0;
        uint256 feesOwed1;
    }
    mapping(bytes32 => Position) public positions;

    // lock the pair for operations that do not modify the price, i.e. everything but swap
    modifier lockNoPriceMovement() {
        uint8 uapb = slot0.unlockedAndPriceBit;
        require(uapb & UNLOCKED_BIT == UNLOCKED_BIT, 'UniswapV3Pair::lock: reentrancy prohibited');
        slot0.unlockedAndPriceBit = uapb ^ UNLOCKED_BIT;
        _;
        slot0.unlockedAndPriceBit = uapb;
    }

    function _getPosition(
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) private view returns (Position storage position) {
        position = positions[keccak256(abi.encodePacked(owner, tickLower, tickUpper))];
    }

    // check for one-time initialization
    function isInitialized() public view override returns (bool) {
        return slot0.sqrtPriceCurrent._x != 0;
    }

    function tickCurrent() public view override returns (int24) {
        return _tickCurrent(slot0);
    }

    function _tickCurrent(Slot0 memory _slot0) internal pure returns (int24) {
        int24 tick = SqrtTickMath.getTickAtSqrtRatio(_slot0.sqrtPriceCurrent);
        if (_slot0.unlockedAndPriceBit & PRICE_BIT == PRICE_BIT) tick--;
        return tick;
    }

    constructor() {
        (address _factory, address _token0, address _token1, uint24 _fee, int24 _tickSpacing) =
            IUniswapV3PairDeployer(msg.sender).parameters();
        factory = _factory;
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickSpacing = _tickSpacing;

        MIN_TICK = (SqrtTickMath.MIN_TICK / _tickSpacing) * _tickSpacing;
        MAX_TICK = (SqrtTickMath.MAX_TICK / _tickSpacing) * _tickSpacing;
    }

    // returns the block timestamp % 2**32
    // overridden for tests
    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp); // truncation is desired
    }

    function setFeeTo(address feeTo_) external override {
        require(msg.sender == IUniswapV3Factory(factory).owner(), 'UniswapV3Pair::setFeeTo: caller not owner');
        feeTo = feeTo_;
    }

    function _updateTick(
        int24 tick,
        int24 current,
        int128 liquidityDelta
    ) private returns (Tick.Info storage tickInfo) {
        tickInfo = tickInfos[tick];

        if (liquidityDelta != 0) {
            if (tickInfo.liquidityGross == 0) {
                assert(liquidityDelta > 0);
                // by convention, we assume that all growth before a tick was initialized happened _below_ the tick
                if (tick <= current) {
                    tickInfo.feeGrowthOutside0 = feeGrowthGlobal0;
                    tickInfo.feeGrowthOutside1 = feeGrowthGlobal1;
                    tickInfo.secondsOutside = _blockTimestamp();
                }
                // safe because we know liquidityDelta is > 0
                tickInfo.liquidityGross = uint128(liquidityDelta);
                tickBitmap.flipTick(tick, tickSpacing);
            } else {
                tickInfo.liquidityGross = uint128(tickInfo.liquidityGross.addi(liquidityDelta));
            }
        }
    }

    function _clearTick(int24 tick) private {
        delete tickInfos[tick];
        tickBitmap.flipTick(tick, tickSpacing);
    }

    function initialize(uint160 sqrtPrice, bytes calldata data) external override {
        require(isInitialized() == false, 'UniswapV3Pair::initialize: pair already initialized');

        slot0 = Slot0({
            blockTimestampLast: _blockTimestamp(),
            tickCumulativeLast: 0,
            sqrtPriceCurrent: FixedPoint96.uq64x96(sqrtPrice),
            unlockedAndPriceBit: 1
        });

        emit Initialized(sqrtPrice);

        // set permanent 1 wei position
        mint(address(0), MIN_TICK, MAX_TICK, 1, data);
    }

    // gets and updates and gets a position with the given liquidity delta
    function _updatePosition(
        address owner,
        int24 tickLower,
        int24 tickUpper,
        int128 liquidityDelta,
        int24 tick
    ) private returns (Position storage position) {
        require(tickLower < tickUpper, 'UniswapV3Pair::_updatePosition: tickLower must be less than tickUpper');
        require(tickLower >= MIN_TICK, 'UniswapV3Pair::_updatePosition: tickLower cannot be less than min tick');
        require(tickUpper <= MAX_TICK, 'UniswapV3Pair::_updatePosition: tickUpper cannot be greater than max tick');
        require(
            tickLower % tickSpacing == 0,
            'UniswapV3Pair::_updatePosition: tickSpacing must evenly divide tickLower'
        );
        require(
            tickUpper % tickSpacing == 0,
            'UniswapV3Pair::_updatePosition: tickSpacing must evenly divide tickUpper'
        );

        position = _getPosition(owner, tickLower, tickUpper);

        if (liquidityDelta < 0) {
            require(
                position.liquidity >= uint128(-liquidityDelta),
                'UniswapV3Pair::_updatePosition: cannot remove more than current position liquidity'
            );
        }

        Tick.Info storage tickInfoLower = _updateTick(tickLower, tick, liquidityDelta);
        Tick.Info storage tickInfoUpper = _updateTick(tickUpper, tick, liquidityDelta);

        require(
            tickInfoLower.liquidityGross <= MAX_LIQUIDITY_GROSS_PER_TICK,
            'UniswapV3Pair::_updatePosition: liquidity overflow in lower tick'
        );
        require(
            tickInfoUpper.liquidityGross <= MAX_LIQUIDITY_GROSS_PER_TICK,
            'UniswapV3Pair::_updatePosition: liquidity overflow in upper tick'
        );

        (FixedPoint128.uq128x128 memory feeGrowthInside0, FixedPoint128.uq128x128 memory feeGrowthInside1) =
            tickInfos.getFeeGrowthInside(tickLower, tickUpper, tick, feeGrowthGlobal0, feeGrowthGlobal1);

        // calculate accumulated fees
        uint256 feesOwed0 =
            FullMath.mulDiv(
                feeGrowthInside0._x - position.feeGrowthInside0Last._x,
                position.liquidity,
                FixedPoint128.Q128
            );
        uint256 feesOwed1 =
            FullMath.mulDiv(
                feeGrowthInside1._x - position.feeGrowthInside1Last._x,
                position.liquidity,
                FixedPoint128.Q128
            );

        // collect protocol fee, if on
        if (feeTo != address(0)) {
            uint256 fee0 = feesOwed0 / 6;
            feesOwed0 -= fee0;
            feeToFees0 += fee0;

            uint256 fee1 = feesOwed1 / 6;
            feesOwed1 -= fee1;
            feeToFees1 += fee1;
        }

        // update the position
        position.liquidity = uint128(position.liquidity.addi(liquidityDelta));
        position.feeGrowthInside0Last = feeGrowthInside0;
        position.feeGrowthInside1Last = feeGrowthInside1;
        position.feesOwed0 += feesOwed0;
        position.feesOwed1 += feesOwed1;

        // when the lower (upper) tick is crossed left to right (right to left), liquidity must be added (removed)
        tickInfoLower.liquidityDelta = tickInfoLower.liquidityDelta.add(liquidityDelta).toInt128();
        tickInfoUpper.liquidityDelta = tickInfoUpper.liquidityDelta.sub(liquidityDelta).toInt128();

        // clear any tick or position data that is no longer needed
        if (liquidityDelta < 0) {
            if (tickInfoLower.liquidityGross == 0) _clearTick(tickLower);
            if (tickInfoUpper.liquidityGross == 0) _clearTick(tickUpper);
            if (position.liquidity == 0) {
                delete position.feeGrowthInside0Last;
                delete position.feeGrowthInside1Last;
            }
        }
    }

    function collectFees(
        int24 tickLower,
        int24 tickUpper,
        address recipient,
        uint256 amount0Requested,
        uint256 amount1Requested
    ) external override lockNoPriceMovement returns (uint256 amount0, uint256 amount1) {
        Position storage position = _updatePosition(msg.sender, tickLower, tickUpper, 0, tickCurrent());

        if (amount0Requested == uint256(-1)) {
            amount0 = position.feesOwed0;
        } else {
            require(amount0Requested <= position.feesOwed0, 'UniswapV3Pair::collectFees: too much token0 requested');
            amount0 = amount0Requested;
        }
        if (amount1Requested == uint256(-1)) {
            amount1 = position.feesOwed1;
        } else {
            require(amount1Requested <= position.feesOwed1, 'UniswapV3Pair::collectFees: too much token1 requested');
            amount1 = amount1Requested;
        }

        position.feesOwed0 -= amount0;
        position.feesOwed1 -= amount1;
        if (amount0 > 0) TransferHelper.safeTransfer(token0, recipient, amount0);
        if (amount1 > 0) TransferHelper.safeTransfer(token1, recipient, amount1);
    }

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) public override lockNoPriceMovement returns (uint256 amount0, uint256 amount1) {
        require(isInitialized(), 'UniswapV3Pair::mint: pair not initialized');

        (int256 amount0Int, int256 amount1Int) =
            _setPosition(
                SetPositionParams({
                    owner: recipient,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    liquidityDelta: int256(amount).toInt128()
                })
            );

        assert(amount0Int >= 0);
        assert(amount1Int >= 0);

        amount0 = uint256(amount0Int);
        amount1 = uint256(amount1Int);

        // collect payment via callback
        {
            (uint256 balance0, uint256 balance1) =
                (IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)));
            IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(amount0, amount1, data);
            require(
                balance0.add(amount0) <= IERC20(token0).balanceOf(address(this)),
                'UniswapV3Pair::mint: insufficient token0 amount'
            );
            require(
                balance1.add(amount1) <= IERC20(token1).balanceOf(address(this)),
                'UniswapV3Pair::mint: insufficient token1 amount'
            );
        }
    }

    function burn(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external override lockNoPriceMovement returns (uint256 amount0, uint256 amount1) {
        require(isInitialized(), 'UniswapV3Pair::burn: pair not initialized');
        require(amount > 0, 'UniswapV3Pair::burn: amount must be greater than 0');

        (int256 amount0Int, int256 amount1Int) =
            _setPosition(
                SetPositionParams({
                    owner: msg.sender,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    liquidityDelta: -int256(amount).toInt128()
                })
            );

        assert(amount0Int <= 0);
        assert(amount1Int <= 0);

        amount0 = uint256(-amount0Int);
        amount1 = uint256(-amount1Int);

        if (amount0 > 0) TransferHelper.safeTransfer(token0, recipient, amount0);
        if (amount1 > 0) TransferHelper.safeTransfer(token1, recipient, amount1);
    }

    struct SetPositionParams {
        // the address that will pay for the mint
        address owner;
        // the lower and upper tick of the position
        int24 tickLower;
        int24 tickUpper;
        // the change in liquidity to effect
        int128 liquidityDelta;
    }

    // effect some changes to a position
    function _setPosition(SetPositionParams memory params) private returns (int256 amount0, int256 amount1) {
        int24 tick = tickCurrent();

        _updatePosition(params.owner, params.tickLower, params.tickUpper, params.liquidityDelta, tick);

        // the current price is below the passed range, so the liquidity can only become in range by crossing from left
        // to right, at which point we'll need _more_ token0 (it's becoming more valuable) so the user must provide it
        if (tick < params.tickLower) {
            amount0 = SqrtPriceMath.getAmount0Delta(
                SqrtTickMath.getSqrtRatioAtTick(params.tickUpper),
                SqrtTickMath.getSqrtRatioAtTick(params.tickLower),
                params.liquidityDelta
            );
        } else if (tick < params.tickUpper) {
            // the current price is inside the passed range
            amount0 = SqrtPriceMath.getAmount0Delta(
                SqrtTickMath.getSqrtRatioAtTick(params.tickUpper),
                slot0.sqrtPriceCurrent,
                params.liquidityDelta
            );
            amount1 = SqrtPriceMath.getAmount1Delta(
                SqrtTickMath.getSqrtRatioAtTick(params.tickLower),
                slot0.sqrtPriceCurrent,
                params.liquidityDelta
            );

            // downcasting is safe because of gross liquidity checks in the _updatePosition call
            slot1.liquidityCurrent = uint128(slot1.liquidityCurrent.addi(params.liquidityDelta));
        } else {
            // the current price is above the passed range, so liquidity can only become in range by crossing from right
            // to left, at which point we need _more_ token1 (it's becoming more valuable) so the user must provide it
            amount1 = SqrtPriceMath.getAmount1Delta(
                SqrtTickMath.getSqrtRatioAtTick(params.tickLower),
                SqrtTickMath.getSqrtRatioAtTick(params.tickUpper),
                params.liquidityDelta
            );
        }
    }

    struct SwapParams {
        // the value of slot0 at the beginning of the swap
        Slot0 slot0Start;
        // the liquidity at the beginning of the swap
        uint128 liquidityStart;
        // the tick at the beginning of the swap
        int24 tickStart;
        // whether the swap is from token 0 to 1, or 1 for 0
        bool zeroForOne;
        // how much is being swapped in (positive), or requested out (negative)
        int256 amountSpecified;
        // the address that receives amount out
        address recipient;
        // the timestamp of the current block
        uint32 blockTimestamp;
        // the data to send in the callback
        bytes data;
    }

    // the top level state of the swap, the results of which are recorded in storage at the end
    struct SwapState {
        // the amount remaining to be swapped in/out of the input/output asset
        int256 amountSpecifiedRemaining;
        // the tick associated with the current price
        int24 tick;
        // current sqrt(price)
        FixedPoint96.uq64x96 sqrtPrice;
        // the global fee growth of the input token
        FixedPoint128.uq128x128 feeGrowthGlobal;
        // the liquidity in range
        uint128 liquidityCurrent;
        // whether the price is at the lower tickCurrent boundary and a tick transition has already occurred
        bool priceBit;
    }

    struct StepComputations {
        // the next tick to swap to from the current tick in the swap direction
        int24 tickNext;
        // whether tickNext is initialized or not
        bool initialized;
        // the price at the beginning of the step
        FixedPoint96.uq64x96 sqrtPriceStart;
        // sqrt(price) for the target tick (1/0)
        FixedPoint96.uq64x96 sqrtPriceTarget;
        // how much is being swapped in in this step
        uint256 amountIn;
        // how much is being swapped out in the current step
        uint256 amountOut;
        // how much fee is paid from the amount in
        uint256 feeAmount;
    }

    // returns the closest parent tick that could be initialized
    // the parent tick is the tick s.t. the input tick is gte parent tick and lt parent tick + tickSpacing
    function closestTick(int24 tick) private view returns (int24) {
        int24 compressed = tick / tickSpacing;
        // round towards negative infinity
        if (tick < 0 && tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function _swap(SwapParams memory params) private returns (uint256 amountCalculated) {
        slot0.unlockedAndPriceBit = params.slot0Start.unlockedAndPriceBit ^ UNLOCKED_BIT;

        SwapState memory state =
            SwapState({
                amountSpecifiedRemaining: params.amountSpecified,
                tick: params.tickStart,
                sqrtPrice: params.slot0Start.sqrtPriceCurrent,
                feeGrowthGlobal: params.zeroForOne ? feeGrowthGlobal0 : feeGrowthGlobal1,
                liquidityCurrent: params.liquidityStart,
                priceBit: params.slot0Start.unlockedAndPriceBit & PRICE_BIT == PRICE_BIT
            });

        while (state.amountSpecifiedRemaining != 0) {
            StepComputations memory step;

            step.sqrtPriceStart = state.sqrtPrice;

            (step.tickNext, step.initialized) = tickBitmap.nextInitializedTickWithinOneWord(
                closestTick(state.tick),
                params.zeroForOne,
                tickSpacing
            );

            if (params.zeroForOne) require(step.tickNext >= MIN_TICK, 'UniswapV3Pair::_swap: crossed min tick');
            else require(step.tickNext <= MAX_TICK, 'UniswapV3Pair::_swap: crossed max tick');

            // get the price for the next tick we're moving toward
            step.sqrtPriceTarget = SqrtTickMath.getSqrtRatioAtTick(step.tickNext);

            (state.sqrtPrice, step.amountIn, step.amountOut, step.feeAmount) = SwapMath.computeSwapStep(
                state.sqrtPrice,
                step.sqrtPriceTarget,
                state.liquidityCurrent,
                state.amountSpecifiedRemaining,
                fee
            );

            // decrement (increment) remaining input (negative output) amount
            // TODO we might not need safemath below
            if (state.amountSpecifiedRemaining > 0) {
                state.amountSpecifiedRemaining -= step.amountIn.add(step.feeAmount).toInt256();
                amountCalculated = amountCalculated.add(step.amountOut);
            } else {
                state.amountSpecifiedRemaining += step.amountOut.toInt256();
                amountCalculated = amountCalculated.add(step.amountIn.add(step.feeAmount));
            }

            // update global fee tracker
            state.feeGrowthGlobal._x += FixedPoint128.fraction(step.feeAmount, state.liquidityCurrent)._x;

            // shift tick if we reached the next price target
            if (state.sqrtPrice._x == step.sqrtPriceTarget._x) {
                // if the tick is initialized, run the tick transition
                if (step.initialized) {
                    Tick.Info storage tickInfo = tickInfos[step.tickNext];

                    // update tick info
                    tickInfo.feeGrowthOutside0 = FixedPoint128.uq128x128(
                        (params.zeroForOne ? state.feeGrowthGlobal._x : feeGrowthGlobal0._x) -
                            tickInfo.feeGrowthOutside0._x
                    );
                    tickInfo.feeGrowthOutside1 = FixedPoint128.uq128x128(
                        (params.zeroForOne ? feeGrowthGlobal1._x : state.feeGrowthGlobal._x) -
                            tickInfo.feeGrowthOutside1._x
                    );
                    tickInfo.secondsOutside = params.blockTimestamp - tickInfo.secondsOutside; // overflow is desired

                    // update liquidityCurrent, subi from right to left, addi from left to right
                    if (params.zeroForOne) {
                        state.liquidityCurrent = uint128(state.liquidityCurrent.subi(tickInfo.liquidityDelta));
                    } else {
                        state.liquidityCurrent = uint128(state.liquidityCurrent.addi(tickInfo.liquidityDelta));
                    }
                }

                state.tick = params.zeroForOne ? step.tickNext - 1 : step.tickNext;
                state.priceBit = params.zeroForOne;
            } else {
                state.priceBit = state.priceBit && params.zeroForOne && state.sqrtPrice._x == step.sqrtPriceStart._x;
                state.tick = SqrtTickMath.getTickAtSqrtRatio(state.sqrtPrice) + (state.priceBit ? int24(-1) : int24(0));
            }
        }

        // update liquidity if it changed
        if (params.liquidityStart != state.liquidityCurrent) {
            slot1.liquidityCurrent = state.liquidityCurrent;
        }

        // the price moved at least one tick, update the accumulator
        if (state.tick != params.tickStart) {
            uint32 _blockTimestampLast = params.slot0Start.blockTimestampLast;
            if (_blockTimestampLast != params.blockTimestamp) {
                slot0.blockTimestampLast = params.blockTimestamp;
                // overflow desired
                slot0.tickCumulativeLast =
                    params.slot0Start.tickCumulativeLast +
                    int56(params.blockTimestamp - _blockTimestampLast) *
                    params.tickStart;
            }
        }

        slot0.sqrtPriceCurrent = state.sqrtPrice;
        // still locked until after the callback, but need to record the price bit
        slot0.unlockedAndPriceBit = state.priceBit ? PRICE_BIT : 0;

        if (params.zeroForOne) {
            feeGrowthGlobal0 = state.feeGrowthGlobal;
        } else {
            feeGrowthGlobal1 = state.feeGrowthGlobal;
        }

        (uint256 amountIn, uint256 amountOut) =
            params.amountSpecified > 0
                ? (uint256(params.amountSpecified), amountCalculated)
                : (amountCalculated, uint256(-params.amountSpecified));

        // perform the token transfers
        {
            (address tokenIn, address tokenOut) = params.zeroForOne ? (token0, token1) : (token1, token0);
            TransferHelper.safeTransfer(tokenOut, params.recipient, amountOut);
            uint256 balanceBefore = IERC20(tokenIn).balanceOf(address(this));
            params.zeroForOne
                ? IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
                    -amountIn.toInt256(),
                    amountOut.toInt256(),
                    params.data
                )
                : IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
                    amountOut.toInt256(),
                    -amountIn.toInt256(),
                    params.data
                );
            require(
                balanceBefore.add(amountIn) >= IERC20(tokenIn).balanceOf(address(this)),
                'UniswapV3Pair::_swap: insufficient input amount'
            );
        }
        slot0.unlockedAndPriceBit = state.priceBit ? PRICE_BIT | UNLOCKED_BIT : UNLOCKED_BIT;
    }

    // positive (negative) numbers specify exact input (output) amounts, return values are output (input) amounts
    function swap(
        bool zeroForOne,
        int256 amountSpecified,
        address recipient,
        bytes calldata data
    ) external override returns (uint256 amountCalculated) {
        require(amountSpecified != 0, 'UniswapV3Pair::swap: amountSpecified must not be 0');

        Slot0 memory _slot0 = slot0;

        require(
            _slot0.unlockedAndPriceBit & UNLOCKED_BIT == UNLOCKED_BIT,
            'UniswapV3Pair::swap: reentrancy prohibited'
        );

        return
            _swap(
                SwapParams({
                    slot0Start: _slot0,
                    tickStart: _tickCurrent(_slot0),
                    liquidityStart: slot1.liquidityCurrent,
                    zeroForOne: zeroForOne,
                    amountSpecified: amountSpecified,
                    recipient: recipient,
                    blockTimestamp: _blockTimestamp(),
                    data: data
                })
            );
    }

    function recover(
        address token,
        address recipient,
        uint256 amount
    ) external override lockNoPriceMovement {
        require(msg.sender == IUniswapV3Factory(factory).owner(), 'UniswapV3Pair::recover: caller not owner');

        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));

        TransferHelper.safeTransfer(token, recipient, amount);

        // check the balance hasn't changed
        require(
            IERC20(token0).balanceOf(address(this)) == token0Balance &&
                IERC20(token1).balanceOf(address(this)) == token1Balance,
            'UniswapV3Pair::recover: cannot recover token0 or token1'
        );
    }

    function collect(uint256 amount0Requested, uint256 amount1Requested)
        external
        override
        lockNoPriceMovement
        returns (uint256 amount0, uint256 amount1)
    {
        if (amount0Requested == uint256(-1)) {
            amount0 = feeToFees0;
        } else {
            require(amount0Requested <= feeToFees0, 'UniswapV3Pair::collect: too much token0 requested');
            amount0 = amount0Requested;
        }
        if (amount1Requested == uint256(-1)) {
            amount1 = feeToFees1;
        } else {
            require(amount1Requested <= feeToFees1, 'UniswapV3Pair::collect: too much token1 requested');
            amount1 = amount1Requested;
        }

        feeToFees0 -= amount0;
        feeToFees1 -= amount1;

        if (amount0 > 0) TransferHelper.safeTransfer(token0, feeTo, amount0);
        if (amount1 > 0) TransferHelper.safeTransfer(token1, feeTo, amount1);
    }
}