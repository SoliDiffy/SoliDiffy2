// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.7;

import {ERC20} from '../../dependencies/openzeppelin/contracts/ERC20.sol';
import {IDelegationToken} from '../../interfaces/IDelegationToken.sol';

/**
 * @title MintableDelegationERC20
 * @dev ERC20 minting logic with delegation
 */
contract MintableDelegationERC20 is IDelegationToken, ERC20 {
  address public delegatee;

  constructor(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) ERC20(name, symbol) {
    _setupDecimals(decimals);
  }

  /**
   * @dev Function to mint tokens
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(uint256 value) external returns (bool) {
    _mint(msg.sender, value);
    return true;
  }

  function delegate(address delegateeAddress) external override {
    delegatee = delegateeAddress;
  }
}
