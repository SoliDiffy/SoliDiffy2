// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.7;

import {VersionedInitializable} from '../../protocol/libraries/aave-upgradeability/VersionedInitializable.sol';

contract MockInitializableImple is VersionedInitializable {
  uint256 internal value;
  string internal text;
  uint256[] internal values;

  uint256 internal constant REVISION = 1;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  function initialize(
    uint256 val,
    string memory txt,
    uint256[] memory vals
  ) external initializer {
    value = val;
    text = txt;
    values = vals;
  }

  function setValue(uint256 newValue) public {
    value = newValue;
  }

  function setValueViaProxy(uint256 newValue) public {
    value = newValue;
  }
}

contract MockInitializableImpleV2 is VersionedInitializable {
  uint256 internal value;
  string internal text;
  uint256[] internal values;

  uint256 internal constant REVISION = 2;

  /**
   * @dev returns the revision number of the contract
   * Needs to be defined in the inherited class as a constant.
   **/
  function getRevision() internal pure override returns (uint256) {
    return REVISION;
  }

  function initialize(
    uint256 val,
    string memory txt,
    uint256[] memory vals
  ) public initializer {
    value = val;
    text = txt;
    values = vals;
  }

  function setValue(uint256 newValue) public {
    value = newValue;
  }

  function setValueViaProxy(uint256 newValue) public {
    value = newValue;
  }
}

contract MockInitializableFromConstructorImple is VersionedInitializable {
  uint256 internal value;

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

  function initialize(uint256 val) public initializer {
    value = val;
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
