/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import {FraudChallenge} from "../FraudChallenge.sol";

/**
 * @title MockedFraudChallenge
 * @notice Mocked implementation of fraud challenge contract
 */
contract MockedFraudChallenge is FraudChallenge {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bool public fraudulentOrderHash;
    bool public fraudulentTradeHash;
    bool public fraudulentPaymentHash;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address owner) internal FraudChallenge(owner) {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function _reset()
    external
    {
        fraudulentOrderHashes.length = 0;
        fraudulentTradeHashes.length = 0;
        fraudulentPaymentHashes.length = 0;
        doubleSpenderWallets.length = 0;
        fraudulentOrderHash = false;
        fraudulentTradeHash = false;
        fraudulentPaymentHash = false;
    }

    function addFraudulentOrderHash(bytes32 hash)
    external
    {
        fraudulentOrderHashes.push(hash);
        emit AddFraudulentOrderHashEvent(hash);
    }

    function addFraudulentTradeHash(bytes32 hash)
    external
    {
        fraudulentTradeHashes.push(hash);
        emit AddFraudulentTradeHashEvent(hash);
    }

    function addFraudulentPaymentHash(bytes32 hash)
    external
    {
        fraudulentPaymentHashes.push(hash);
        emit AddFraudulentPaymentHashEvent(hash);
    }

    function addDoubleSpenderWallet(address wallet)
    external
    {
        doubleSpenderWallets.push(wallet);
        emit AddDoubleSpenderWalletEvent(wallet);
    }

    function setFraudulentOrderOperatorHash(bool _fraudulentOrderHash)
    external
    {
        fraudulentOrderHash = _fraudulentOrderHash;
    }

    function isFraudulentOrderHash(bytes32)
    external
    view
    returns (bool)
    {
        return fraudulentOrderHash;
    }

    function setFraudulentTradeHash(bool _fraudulentTradeHash)
    external
    {
        fraudulentTradeHash = _fraudulentTradeHash;
    }

    function isFraudulentTradeHash(bytes32)
    external
    view
    returns (bool)
    {
        return fraudulentTradeHash;
    }

    function setFraudulentPaymentOperatorHash(bool _fraudulentPaymentHash)
    public
    {
        fraudulentPaymentHash = _fraudulentPaymentHash;
    }

    function isFraudulentPaymentHash(bytes32)
    public
    view
    returns (bool)
    {
        return fraudulentPaymentHash;
    }
}
