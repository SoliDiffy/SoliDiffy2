/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import {NahmiiTypesLib} from "../NahmiiTypesLib.sol";

/**
 * @title MockedNullSettlementDispute
 * @notice Mocked implementation of null settlement dispute contract
 */
contract MockedNullSettlementDispute {
    uint256 public _challengeByOrderCount;
    uint256 public _challengeByTradeCount;
    uint256 public _challengeByPaymentCount;

    function _reset()
    external
    {
        _challengeByOrderCount = 0;
        _challengeByTradeCount = 0;
        _challengeByPaymentCount = 0;
    }

    function challengeByOrder(NahmiiTypesLib.Order, address)
    external
    {
        _challengeByOrderCount++;
    }

    function challengeByTrade(address, NahmiiTypesLib.Trade, address)
    external
    {
        _challengeByTradeCount++;
    }

    function challengeByPayment(address, NahmiiTypesLib.Payment, address)
    external
    {
        _challengeByPaymentCount++;
    }
}