// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.7;

import { IMapleProxyFactory } from "../modules/maple-proxy-factory/contracts/interfaces/IMapleProxyFactory.sol";

import { ERC20Helper }  from "../modules/erc20-helper/src/ERC20Helper.sol";
import { Liquidator }   from "../modules/liquidations/contracts/Liquidator.sol";
import { MapleProxied } from "../modules/maple-proxy-factory/contracts/MapleProxied.sol";

import { IDebtLocker }                                                                from "./interfaces/IDebtLocker.sol";
import { IERC20Like, IMapleGlobalsLike, IMapleLoanLike, IPoolLike, IPoolFactoryLike } from "./interfaces/Interfaces.sol";

import { DebtLockerStorage } from "./DebtLockerStorage.sol";

/// @title DebtLocker holds custody of LoanFDT tokens.
contract DebtLocker is IDebtLocker, DebtLockerStorage, MapleProxied {

    /********************************/
    /*** Administrative Functions ***/
    /********************************/

    

    

    

    /*******************************/
    /*** Pool Delegate Functions ***/
    /*******************************/

    

    

    

    

    

    

    

    /**********************/
    /*** View Functions ***/
    /**********************/

    function allowedSlippage() external view override returns (uint256 allowedSlippage_) {
        return _allowedSlippage;
    }

    function amountRecovered() external view override returns (uint256 amountRecovered_) {
        return _amountRecovered;
    }

    function factory() external view override returns (address factory_) {
        return _factory();
    }

    function fundsToCapture() external view override returns (uint256 fundsToCapture_) {
        return _fundsToCapture;
    }

    function getExpectedAmount(uint256 swapAmount_) external view override returns (uint256 returnAmount_) {
        address collateralAsset = IMapleLoanLike(_loan).collateralAsset();
        address fundsAsset      = IMapleLoanLike(_loan).fundsAsset();

        uint256 oracleAmount =
            swapAmount_
                * IMapleGlobalsLike(_getGlobals()).getLatestPrice(collateralAsset)  // Convert from `fromAsset` value.
                * 10 ** IERC20Like(fundsAsset).decimals()                           // Convert to `toAsset` decimal precision.
                * (10_000 - _allowedSlippage)                                       // Multiply by allowed slippage basis points
                / IMapleGlobalsLike(_getGlobals()).getLatestPrice(fundsAsset)       // Convert to `toAsset` value.
                / 10 ** IERC20Like(collateralAsset).decimals()                      // Convert from `fromAsset` decimal precision.
                / 10_000;                                                           // Divide basis points for slippage

        uint256 minRatioAmount = swapAmount_ * _minRatio / 10 ** IERC20Like(collateralAsset).decimals();

        return oracleAmount > minRatioAmount ? oracleAmount : minRatioAmount;
    }

    function implementation() external view override returns (address) {
        return _implementation();
    }

    function investorFee() external view override returns (uint256 investorFee_) {
        return IMapleGlobalsLike(_getGlobals()).investorFee();
    }

    function liquidator() external view override returns (address liquidator_) {
        return _liquidator;
    }

    function loan() external view override returns (address loan_) {
        return _loan;
    }

    function mapleTreasury() external view override returns (address mapleTreasury_) {
        return IMapleGlobalsLike(_getGlobals()).mapleTreasury();
    }

    function minRatio() external view override returns (uint256 minRatio_) {
        return _minRatio;
    }

    function pool() external view override returns (address pool_) {
        return _pool;
    }

    function poolDelegate() external override view returns(address) {
        return _getPoolDelegate();
    }

    function principalRemainingAtLastClaim() external view override returns (uint256 principalRemainingAtLastClaim_) {
        return _principalRemainingAtLastClaim;
    }

    function repossessed() external view override returns (bool repossessed_) {
        return _repossessed;
    }

    function treasuryFee() external view override returns (uint256 treasuryFee_) {
        return IMapleGlobalsLike(_getGlobals()).treasuryFee();
    }

    /**************************/
    /*** Internal Functions ***/
    /**************************/

    function _handleClaimOfRepossessed() internal returns (uint256[7] memory details_) {
        require(!_isLiquidationActive(), "DL:HCOR:LIQ_NOT_FINISHED");

        address fundsAsset       = IMapleLoanLike(_loan).fundsAsset();
        uint256 principalToCover = _principalRemainingAtLastClaim;      // Principal remaining at time of liquidation
        uint256 fundsCaptured    = _fundsToCapture;

        // Funds recovered from liquidation and any unclaimed previous payment amounts
        uint256 recoveredFunds = IERC20Like(fundsAsset).balanceOf(address(this)) - fundsCaptured;  

        // If `recoveredFunds` is greater than `principalToCover`, the remaining amount is treated as interest in the context of the pool.
        // If `recoveredFunds` is less than `principalToCover`, the difference is registered as a shortfall.
        details_[0] = recoveredFunds + fundsCaptured;
        details_[1] = recoveredFunds > principalToCover ? recoveredFunds - principalToCover : 0;
        details_[2] = fundsCaptured;
        details_[5] = recoveredFunds > principalToCover ? principalToCover : recoveredFunds;
        details_[6] = principalToCover > recoveredFunds ? principalToCover - recoveredFunds : 0;

        require(ERC20Helper.transfer(fundsAsset, _pool, recoveredFunds + fundsCaptured), "DL:HCOR:TRANSFER");

        _fundsToCapture = uint256(0);
        _repossessed    = false;
    }

    function _handleClaim() internal returns (uint256[7] memory details_) {
        // Get loan state variables needed
        uint256 claimableFunds = IMapleLoanLike(_loan).claimableFunds();

        require(claimableFunds > uint256(0), "DL:HC:NOTHING_TO_CLAIM");

        // Send funds to pool
        IMapleLoanLike(_loan).claimFunds(claimableFunds, _pool);

        uint256 currentPrincipalRemaining = IMapleLoanLike(_loan).principal();

        // Determine how much of `claimableFunds` is principal
        uint256 principalPortion = _principalRemainingAtLastClaim - currentPrincipalRemaining;

        // Update state variables
        _principalRemainingAtLastClaim = currentPrincipalRemaining;

        // Set return values
        // Note: All fees get deducted and transferred during `loan.fundLoan()` that omits the need to
        // return the fees distribution to the pool.
        details_[0] = claimableFunds;
        details_[1] = claimableFunds - principalPortion;
        details_[2] = principalPortion;

        if (_fundsToCapture > uint256(0)) {
            details_[0] += _fundsToCapture;
            details_[2] += _fundsToCapture;

            require(ERC20Helper.transfer(IMapleLoanLike(_loan).fundsAsset(), _pool, _fundsToCapture), "DL:HC:CAPTURE_FAILED");

            _fundsToCapture = uint256(0);
        }
    }

    /*******************************/
    /*** Internal View Functions ***/
    /*******************************/

    function _getGlobals() internal view returns (address) {
        return IPoolFactoryLike(IPoolLike(_pool).superFactory()).globals();
    }

    function _getPoolDelegate() internal view returns(address) {
        return IPoolLike(_pool).poolDelegate();
    }

    function _isLiquidationActive() internal view returns (bool) {
        return _liquidator != address(0) && IERC20Like(IMapleLoanLike(_loan).collateralAsset()).balanceOf(_liquidator) > 0;
    }

}
