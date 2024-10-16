pragma solidity ^0.5.13;

import "../Validators.sol";
import "../../common/FixidityLib.sol";

/**
 * @title A wrapper around Validators that exposes onlyVm functions for testing.
 */
contract ValidatorsTest is Validators {
  function updateValidatorScoreFromSigner(address signer, uint256 uptime) public {
    return _updateValidatorScoreFromSigner(signer, uptime);
  }

  function distributeEpochPaymentsFromSigner(address signer, uint256 maxPayment)
    public
    returns (uint256)
  {
    return _distributeEpochPaymentsFromSigner(signer, maxPayment);
  }
}
