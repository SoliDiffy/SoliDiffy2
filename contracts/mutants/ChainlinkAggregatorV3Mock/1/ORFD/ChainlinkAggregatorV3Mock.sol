// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.6;
import "../ISourceMock.sol";


contract ChainlinkAggregatorV3Mock is ISourceMock {
    int public price;   // Prices in Chainlink can be negative (!)
    uint public timestamp;
    uint8 public decimals = 18;  // Decimals provided in the oracle prices

    

    function latestRoundData() public view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, price, 0, timestamp, 0);
    }
}
