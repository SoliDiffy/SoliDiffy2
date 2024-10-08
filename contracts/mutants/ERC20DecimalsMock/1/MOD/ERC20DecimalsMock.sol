// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../token/ERC20/ERC20.sol";

contract ERC20DecimalsMock is ERC20 {
    constructor (string memory name, string memory symbol, uint8 decimals) public  {
        _setupDecimals(decimals);
    }
}
