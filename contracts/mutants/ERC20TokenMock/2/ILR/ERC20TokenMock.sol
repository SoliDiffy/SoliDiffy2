pragma solidity ^0.4.24;


import '../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract ERC20TokenMock is StandardToken {
	constructor() public {
		name = "TokenERC20Mock";
		symbol = "TOKENMOCK";
		decimals = 17;
		totalSupply_ = 999999;
		balances[msg.sender] = totalSupply_;
	}
}
