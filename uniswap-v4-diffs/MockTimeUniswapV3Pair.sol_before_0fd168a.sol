// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.6.11;
pragma experimental ABIEncoderV2;

import '../UniswapV3Pair.sol';

// used for testing time dependent behavior
contract MockTimeUniswapV3Pair is UniswapV3Pair {
    uint32 public time;

    constructor(address factory, address tokenA, address tokenB) public UniswapV3Pair(factory, tokenA, tokenB) {}

    function setTime(uint32 _time) external {
        time = _time;
    }

    function _blockTimestamp() internal override view returns (uint32) {
        return time;
    }
}