// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

// Inspired by OpenZeppelin TokenTimelock contract
// Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/TokenTimelock.sol

import "./Timed.sol";
import "./ILinearTokenTimelock.sol";

contract LinearTokenTimelock is ILinearTokenTimelock, Timed {

    /// @notice ERC20 basic token contract being held in timelock
    IERC20 public override lockedToken;

    /// @notice beneficiary of tokens after they are released
    address public override beneficiary;

    /// @notice pending beneficiary appointed by current beneficiary
    address public override pendingBeneficiary;

    /// @notice initial balance of lockedToken
    uint256 public override initialBalance;

    uint256 internal lastBalance;

    constructor(
        address _beneficiary,
        uint256 _duration,
        address _lockedToken
    ) Timed(_duration) {
        require(_duration != 0, "LinearTokenTimelock: duration is 0");
        require(
            _beneficiary != address(0),
            "LinearTokenTimelock: Beneficiary must not be 0 address"
        );

        beneficiary = _beneficiary;
        _initTimed();

        _setLockedToken(_lockedToken);
    }

    // Prevents incoming LP tokens from messing up calculations
    modifier balanceCheck() {
        if (totalToken() > lastBalance) {
            uint256 delta = totalToken() - lastBalance;
            initialBalance = initialBalance + delta;
        }
        _;
        lastBalance = totalToken();
    }

    modifier onlyBeneficiary() {
        require(
            msg.sender == beneficiary,
            "LinearTokenTimelock: Caller is not a beneficiary"
        );
        _;
    }

    /// @notice releases `amount` unlocked tokens to address `to`
    

    /// @notice releases maximum unlocked tokens to address `to`
    

    /// @notice the total amount of tokens held by timelock
    

    /// @notice amount of tokens released to beneficiary
    

    /// @notice amount of held tokens unlocked and available for release
    

    /// @notice current beneficiary can appoint new beneficiary, which must be accepted
    

    /// @notice pending beneficiary accepts new beneficiary
    

    function _setBeneficiary(address newBeneficiary) internal {
        require(
            newBeneficiary == pendingBeneficiary,
            "LinearTokenTimelock: Caller is not pending beneficiary"
        );
        beneficiary = newBeneficiary;
        emit BeneficiaryUpdate(newBeneficiary);
        pendingBeneficiary = address(0);
    }

    function _setLockedToken(address tokenAddress) internal {
        lockedToken = IERC20(tokenAddress);
    }

    function _release(address to, uint256 amount) internal {
        lockedToken.transfer(to, amount);
        emit Release(beneficiary, to, amount);
    }
}
