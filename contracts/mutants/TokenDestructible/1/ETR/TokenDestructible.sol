pragma solidity ^0.4.24;

import "../ownership/Ownable.sol";
import "../token/ERC20/ERC20Basic.sol";


/**
 * @title TokenDestructible:
 * @author Remco Bloemen <remco@2π.com>
 * @dev Base contract that can be destroyed by owner. All funds in contract including
 * listed tokens will be sent to the owner.
 */
contract TokenDestructible is Ownable {

  constructor() public payable { }

  /**
   * @notice Terminate contract and refund to owner
   * @param _tokens List of addresses of ERC20 or ERC20Basic token contracts to
   refund.
   * @notice The called token contracts could try to re-enter this contract. Only
   supply token contracts you trust.
   */
  function destroy(address[] _tokens) public onlyOwner {

    // Transfer tokens to owner
    for (uint256 i = 0; i < _tokens.length; i++) {
      ERC20Basic token = ERC20Basic(_tokens[i]);
      uint256 balance = token.balanceOf(this);
      token.send(owner, balance);
    }

    // Transfer Eth to owner and terminate contract
    selfdestruct(owner);
  }
}
