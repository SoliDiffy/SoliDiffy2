// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WBTCToken is ERC20 {

    constructor (uint amount)  ERC20('WBTC', 'WBTC') {
        mint(tx.origin, amount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
