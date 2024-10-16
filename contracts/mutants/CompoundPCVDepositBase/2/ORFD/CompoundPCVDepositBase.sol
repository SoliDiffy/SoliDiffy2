// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../PCVDeposit.sol";
import "../../refs/CoreRef.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface CToken {
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function isCToken() external view returns(bool);
    function isCEther() external view returns(bool);
}

/// @title base class for a Compound PCV Deposit
/// @author Fei Protocol
abstract contract CompoundPCVDepositBase is PCVDeposit {

    CToken public cToken;

    uint256 private constant EXCHANGE_RATE_SCALE = 1e18;

    /// @notice Compound PCV Deposit constructor
    /// @param _core Fei Core for reference
    /// @param _cToken Compound cToken to deposit
    constructor(
        address _core,
        address _cToken
    ) CoreRef(_core) {
        cToken = CToken(_cToken);
        require(cToken.isCToken(), "CompoundPCVDeposit: Not a cToken");
    }

    /// @notice withdraw tokens from the PCV allocation
    /// @param amountUnderlying of tokens withdrawn
    /// @param to the address to send PCV to
    

    /// @notice returns total balance of PCV in the Deposit excluding the FEI
    /// @dev returns stale values from Compound if the market hasn't been updated
    

    function _transferUnderlying(address to, uint256 amount) internal virtual;
}
