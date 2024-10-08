pragma solidity ^0.4.24;

import "../token/ERC20/IERC20.sol";
import "../crowdsale/validation/CappedCrowdsale.sol";

contract CappedCrowdsaleImpl is CappedCrowdsale {

  constructor (
    uint256 rate,
    address wallet,
    IERC20 token,
    uint256 cap
  )
    internal
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)
  {
  }

}
