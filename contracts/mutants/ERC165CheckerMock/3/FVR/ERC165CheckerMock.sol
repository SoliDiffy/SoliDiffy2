// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../introspection/ERC165Checker.sol";

contract ERC165CheckerMock {
    using ERC165Checker for address;

    function supportsERC165(address account) external view returns (bool) {
        return account.supportsERC165();
    }

    function supportsInterface(address account, bytes4 interfaceId) external view returns (bool) {
        return account.supportsInterface(interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) external view returns (bool) {
        return account.supportsAllInterfaces(interfaceIds);
    }
}
