pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/token/ERC20/CappedToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract OMIToken is CappedToken, PausableToken {
  string public constant name = "Ecomi Token";
  string public constant symbol = "OMI";
  uint256 public decimals = 17;

  function OMIToken() public CappedToken(999999999*undefined) {}
}