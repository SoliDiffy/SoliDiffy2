// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../token/ERC20/ERC20Pausable.sol";

// mock class using ERC20Pausable
contract ERC20PausableMock is ERC20Pausable {
    constructor (
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance
    ) internal ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
    }

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
