// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockedWallet is Ownable {
    address public creator;
    address public toWallet;
    address public mafacoin;
    uint256 public unlockDate;
    uint256 public createdAt;

    

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        require(block.timestamp >= unlockDate, "Cannot unlock tokens yet!");
        ERC20 token = ERC20(mafacoin);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(toWallet, tokenBalance);
        emit Withdrew(mafacoin, msg.sender, tokenBalance);
    }

    function info()
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        ERC20 token = ERC20(mafacoin);
        uint256 tokenBalance = token.balanceOf(address(this));
        return (creator, toWallet, unlockDate, createdAt, tokenBalance);
    }

    event Received(address from, uint256 amount);
    event Withdrew(address tokenContract, address to, uint256 amount);
}
