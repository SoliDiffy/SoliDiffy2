// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.10;

import {ERC20} from "";

contract Currency is ERC20("", "") {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
