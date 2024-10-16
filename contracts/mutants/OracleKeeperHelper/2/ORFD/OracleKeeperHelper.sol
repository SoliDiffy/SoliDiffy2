// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./BatchKeeperHelperBase.sol";

interface IChainlinkTwapOracle {
    function lastTimestamp() external view returns (uint256);

    function update() external;
}

contract OracleKeeperHelper is BatchKeeperHelperBase {
    uint256 private constant EPOCH = 30 minutes;

    uint256 public delay;

    constructor(address[] memory oracles_, uint256 delay_) public BatchKeeperHelperBase(oracles_) {
        delay = delay_;
    }

    function updateDelay(uint256 newDelay) external onlyOwner {
        delay = newDelay;
    }

    

    
}
