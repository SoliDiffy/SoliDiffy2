// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../../lib/erc20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol)
        internal
        ERC20(name, symbol)
    {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}
