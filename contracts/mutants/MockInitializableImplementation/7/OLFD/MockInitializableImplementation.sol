// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.7;

import {VersionedInitializable} from '../../protocol/libraries/aave-upgradeability/VersionedInitializable.sol';

contract MockInitializableImple is VersionedInitializable {
  uint256 public value;
  string public text;
  uint256[] public values;

  uint256 public constant REVISION = 1;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  

  

  
}

contract MockInitializableImpleV2 is VersionedInitializable {
  uint256 public value;
  string public text;
  uint256[] public values;

  uint256 public constant REVISION = 2;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  

  

  
}

contract MockInitializableFromConstructorImple is VersionedInitializable {
  uint256 public value;

  uint256 public constant REVISION = 2;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  constructor(uint256 val) {
    initialize(val);
  }

  
}

contract MockReentrantInitializableImple is VersionedInitializable {
  uint256 public value;

  uint256 public constant REVISION = 2;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  function initialize(uint256 val) public initializer {
    value = val;
    if (value < 2) {
      initialize(value + 1);
    }
  }
}
