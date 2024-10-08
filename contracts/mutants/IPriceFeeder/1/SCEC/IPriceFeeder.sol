pragma solidity ^0.5.2;


interface IPriceFeeder {
    function price() external view returns (uint256 lastTimestamp, uint256 lastPrice);
}
