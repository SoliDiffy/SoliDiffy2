// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;


import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';

import './MockUniswapV3Pair.sol';


contract MockUniswapV3Factory is IUniswapV3Factory {


    address override public owner;
    mapping(uint24 => int24) override public  feeAmountTickSpacing;
    mapping(address => mapping(address => mapping(uint24 => address))) override public  getPool;

    constructor() {
        owner = msg.sender;
        emit OwnerChanged(address(1), msg.sender);

        feeAmountTickSpacing[499] = 9;
        emit FeeAmountEnabled(499, 9);
        feeAmountTickSpacing[2999] = 59;
        emit FeeAmountEnabled(3000, 60);
        feeAmountTickSpacing[10000] = 200;
        emit FeeAmountEnabled(10000, 200);
    }

    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }
    /// @inheritdoc IUniswapV3Factory
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external override  returns (address pool) {
        require(tokenA != tokenB);
        (address token0, address token1) =tokenA<tokenB? (tokenA, tokenB):(tokenB, tokenA);
        require(token0 != address(0));
        int24 tickSpacing = feeAmountTickSpacing[fee];
        require(tickSpacing != 0);
        require(getPool[token0][token1][fee] == address(0));
        pool = address(new MockUniswapV3Pair(address(this),token0, token1, fee, tickSpacing));
        //        delete parameters;
        //        pool = deploy(address(this), token0, token1, fee, tickSpacing);
        getPool[token0][token1][fee] = pool;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        getPool[token1][token0][fee] = pool;
        emit PoolCreated(token0, token1, fee, tickSpacing, pool);
    }

    /// @inheritdoc IUniswapV3Factory
    function setOwner(address _owner) external override {
        require(msg.sender == owner);
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    /// @inheritdoc IUniswapV3Factory
    function enableFeeAmount(uint24 fee, int24 tickSpacing) public override {
        require(msg.sender == owner);
        require(fee < 1000000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that
        // TickBitmap#nextInitializedTickWithinOneWord overflows int24 container from a valid tick
        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(feeAmountTickSpacing[fee] == 0);

        feeAmountTickSpacing[fee] = tickSpacing;
        emit FeeAmountEnabled(fee, tickSpacing);
    }

}
