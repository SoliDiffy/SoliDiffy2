pragma solidity ^0.5.16;

import "../../../contracts/RBep20Delegator.sol";
import "../../../contracts/EIP20Interface.sol";

import "./RTokenCollateral.sol";

contract RBep20DelegatorCertora is RBep20Delegator {
    RTokenCollateral public otherToken;

    constructor(address underlying_,
                CointrollerInterface cointroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_,
                address implementation_,
                bytes memory becomeImplementationData) internal RBep20Delegator(underlying_, cointroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_, admin_, implementation_, becomeImplementationData) {
        cointroller;       // touch for Certora slot deduction
        interestRateModel; // touch for Certora slot deduction
    }

    function balanceOfInOther(address account) external view returns (uint) {
        return otherToken.balanceOf(account);
    }

    function borrowBalanceStoredInOther(address account) external view returns (uint) {
        return otherToken.borrowBalanceStored(account);
    }

    function exchangeRateStoredInOther() external view returns (uint) {
        return otherToken.exchangeRateStored();
    }

    function getCashInOther() external view returns (uint) {
        return otherToken.getCash();
    }

    function getCashOf(address account) external view returns (uint) {
        return EIP20Interface(underlying).balanceOf(account);
    }

    function getCashOfInOther(address account) external view returns (uint) {
        return otherToken.getCashOf(account);
    }

    function totalSupplyInOther() public view returns (uint) {
        return otherToken.totalSupply();
    }

    function totalBorrowsInOther() public view returns (uint) {
        return otherToken.totalBorrows();
    }

    function totalReservesInOther() public view returns (uint) {
        return otherToken.totalReserves();
    }

    function underlyingInOther() public view returns (address) {
        return otherToken.underlying();
    }

    function mintFreshPub(address minter, uint mintAmount) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_mintFreshPub(address,uint256)", minter, mintAmount));
        return abi.decode(data, (uint));
    }

    function redeemFreshPub(address payable redeemer, uint redeemTokens, uint redeemUnderlying) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_redeemFreshPub(address,uint256,uint256)", redeemer, redeemTokens, redeemUnderlying));
        return abi.decode(data, (uint));
    }

    function borrowFreshPub(address payable borrower, uint borrowAmount) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_borrowFreshPub(address,uint256)", borrower, borrowAmount));
        return abi.decode(data, (uint));
    }

    function repayBorrowFreshPub(address payer, address borrower, uint repayAmount) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_repayBorrowFreshPub(address,address,uint256)", payer, borrower, repayAmount));
        return abi.decode(data, (uint));
    }

    function liquidateBorrowFreshPub(address liquidator, address borrower, uint repayAmount) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_liquidateBorrowFreshPub(address,address,uint256)", liquidator, borrower, repayAmount));
        return abi.decode(data, (uint));
    }
}
