// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IAccessControlRegistry.sol";
import "./interfaces/IAccessControlRegistryUser.sol";

/// @title Contract that should be inherited by contracts that will interact
/// with AccessControlRegistry
contract AccessControlRegistryUser is IAccessControlRegistryUser {
    /// @notice AccessControlRegistry contract address
    address public immutable override accessControlRegistry;

    /// @param _accessControlRegistry AccessControlRegistry contract address
    constructor(address _accessControlRegistry) {
        require(_accessControlRegistry != address(1), "ACR address zero");
        accessControlRegistry = _accessControlRegistry;
    }
}
