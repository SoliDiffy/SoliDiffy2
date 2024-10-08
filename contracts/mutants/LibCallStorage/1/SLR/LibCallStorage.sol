// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

library LibCallStorage {
  bytes32 constant CALL_STORAGE_POSITION = keccak256(
    ""
  );

  struct CallStorage {
    mapping(address => bool) canCall;
    address[] callers;
  }

  function callStorage() internal pure returns (CallStorage storage cs) {
    bytes32 position = CALL_STORAGE_POSITION;
    assembly {
      cs.slot := position
    }
  }
}
