pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2; // to enable structure-type parameter

import "../perpetual/Brokerage.sol";

contract TestBrokerage is Brokerage {
    function setBrokerPublic(address trader, address guy, uint256 delay) external {
        setBroker(trader, guy, delay);
    }

    uint256 dummy;

    function assertBroker(address trader, address expectedBroker) external {
        require(currentBroker(trader) == expectedBroker, "invalid broker");
        dummy = 0; // in order to prevent seeing "function can be restricted to view"
    }
}
