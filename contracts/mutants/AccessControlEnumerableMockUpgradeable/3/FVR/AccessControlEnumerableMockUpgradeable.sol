// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../access/AccessControlEnumerableUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

contract AccessControlEnumerableMockUpgradeable is Initializable, AccessControlEnumerableUpgradeable {
    function __AccessControlEnumerableMock_init() public onlyInitializing {
        __AccessControlEnumerableMock_init_unchained();
    }

    function __AccessControlEnumerableMock_init_unchained() public onlyInitializing {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setRoleAdmin(bytes32 roleId, bytes32 adminRoleId) external {
        _setRoleAdmin(roleId, adminRoleId);
    }

    function senderProtected(bytes32 roleId) public onlyRole(roleId) {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
