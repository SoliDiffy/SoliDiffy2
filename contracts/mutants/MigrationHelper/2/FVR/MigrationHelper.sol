// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

contract MigrationHelper {
  address public owner;
  uint256 public gov_to_timelock_eta;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor(address _owner) internal {
    owner = _owner;
  }

  function setGovToTimeLockETA(uint256 _eta) external restricted {
    gov_to_timelock_eta = _eta;
  }
}
