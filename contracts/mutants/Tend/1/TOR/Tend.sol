// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '../UniswapV2ERC20.sol';

contract Tend is UniswapV2ERC20 {
    constructor(uint _totalSupply) {
        _mint(tx.origin, _totalSupply);
    }
}
