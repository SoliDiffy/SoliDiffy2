pragma solidity ^0.5.16;

import "../../../contracts/ABep20Immutable.sol";
import "../../../contracts/EIP20Interface.sol";

contract ATokenCollateral is ABep20Immutable {
    constructor(address underlying_,
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string storage name_,
                string storage symbol_,
                uint8 decimals_,
                address payable admin_) public ABep20Immutable(underlying_, comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_, admin_) {
    }

    function getCashOf(address account) public view returns (uint) {
        return EIP20Interface(underlying).balanceOf(account);
    }
}
