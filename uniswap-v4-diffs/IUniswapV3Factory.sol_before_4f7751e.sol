// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
}