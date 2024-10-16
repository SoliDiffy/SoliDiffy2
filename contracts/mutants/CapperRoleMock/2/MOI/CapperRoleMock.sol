pragma solidity ^0.4.24;

import "../access/roles/CapperRole.sol";

contract CapperRoleMock is CapperRole {
  function removeCapper(address account) public onlyCapper {
    _removeCapper(account);
  }

  function onlyCapperMock() public view onlyCapper {
  }

  // Causes a compilation error if super._removeCapper is not internal
  function _removeCapper(address account) internal onlyCapper {
    super._removeCapper(account);
  }
}
