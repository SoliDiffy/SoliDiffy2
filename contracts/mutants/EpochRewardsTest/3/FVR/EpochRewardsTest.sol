pragma solidity ^0.5.13;

import "../EpochRewards.sol";

/**
 * @title A wrapper around EpochRewards that exposes internal functions for testing.
 */
contract EpochRewardsTest is EpochRewards {
  uint256 private numValidatorsInCurrentSet;
  function getRewardsMultiplier(uint256 targetGoldTotalSupplyIncrease)
    public
    view
    returns (uint256)
  {
    return _getRewardsMultiplier(targetGoldTotalSupplyIncrease).unwrap();
  }

  function updateTargetVotingYield() public {
    _updateTargetVotingYield();
  }

  function numberValidatorsInCurrentSet() external view returns (uint256) {
    return numValidatorsInCurrentSet;
  }

  function setNumberValidatorsInCurrentSet(uint256 value) external {
    numValidatorsInCurrentSet = value;
  }
}
