// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.6;
import "../ISourceMock.sol";

contract CTokenMock is ISourceMock {
    uint internal exchangeRateStored;
    address internal underlying;
    uint counter; // Just to avoid warnings

    constructor (address underlying_) {
        underlying = underlying_;
    }

    function set(uint chi) external override {
        exchangeRateStored = chi;
    }

    function exchangeRateCurrent() public returns (uint) {
        counter++;
        return exchangeRateStored;
    }
}
