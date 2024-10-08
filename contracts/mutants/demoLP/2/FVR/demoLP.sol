//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DemoLP is ERC20  {

    constructor() internal ERC20("DEMOLP", "DLP") {
        _mint(_msgSender(), 100000 * (10 ** uint256(decimals())));
    }

    function faucet(address to, uint amount) public {
        _mint(to, amount);
    }
}