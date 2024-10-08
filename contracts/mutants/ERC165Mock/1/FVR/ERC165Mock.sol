// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../introspection/ERC165.sol";

contract ERC165Mock is ERC165 {
    function registerInterface(bytes4 interfaceId) external {
        _registerInterface(interfaceId);
    }
}
