pragma solidity = 0.5.16;


import "";
import "";


contract CrodexToken is ERC20Detailed, ERC20{
    constructor() ERC20Detailed('Crodex Token', 'CRX', 18) public {
        _mint(msg.sender, 100000_000000000000000000);
    }
}