// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

library LibReentryProtectionStorage {
  bytes32 constant REENTRY_STORAGE_POSITION = keccak256(
    "diamond.standard.reentry.storage"
  );

  struct RPStorage {
    uint256 lockCounter;
  }

  function rpStorage() public pure returns (RPStorage storage bs) {
    bytes32 position = REENTRY_STORAGE_POSITION;
    assembly {
      bs.slot := position
    }
  }
}
