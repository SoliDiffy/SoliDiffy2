// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../proxy/Initializable.sol";

/**
 * @title InitializableMock
 * @dev This contract is a mock to test initializable functionality
 */
contract InitializableMock is Initializable {

  bool public initializerRan;
  uint256 public x;

  function initialize() public initializer {
    initializerRan = true;
  }

  function initializeNested() public initializer {
    initialize();
  }

  function initializeWithX(uint256 _x) public  initializer {
    x = _x;
  }

  function nonInitializable(uint256 _x) public  {
    x = _x;
  }

  function fail() public pure {
    require(false, "InitializableMock forced failure");
  }

}
