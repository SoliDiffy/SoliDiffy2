// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "./interfaces/IOrderedCallbacksArray.sol";

/**
  * @title Contract defining an ordered callbacks array supporting add/insert/remove ops
  *
  * Contract adds permission modifiers ontop of `IOderedCallbacksArray` interface functions.
  * Only the `VOTING` address can invoke storage mutating (add/insert/remove) functions.
  */
contract OrderedCallbacksArray is IOrderedCallbacksArray {
    uint256 public constant MAX_CALLBACKS_COUNT = 16;

    address public immutable VOTING;

    address[] public callbacks;

    modifier onlyVoting() {
        require(msg.sender == VOTING, "MSG_SENDER_MUST_BE_VOTING");
        _;
    }

    constructor(address _voting) {
        require(_voting != address(0), "VOTING_ZERO_ADDRESS");

        VOTING = _voting;
    }

    

    

    

    

    function _insertCallback(address _callback, uint256 _atIndex) private {
        require(_callback != address(0), "CALLBACK_ZERO_ADDRESS");

        uint256 oldCArrayLength = callbacks.length;
        require(_atIndex <= oldCArrayLength, "INDEX_IS_OUT_OF_RANGE");
        require(oldCArrayLength < MAX_CALLBACKS_COUNT, "MAX_CALLBACKS_COUNT_EXCEEDED");

        emit CallbackAdded(_callback, _atIndex);

        callbacks.push();

        if (oldCArrayLength > 0) {
            for (uint256 cIndex = oldCArrayLength; cIndex > _atIndex; cIndex--) {
                callbacks[cIndex] = callbacks[cIndex-1];
            }
        }

        callbacks[_atIndex] = _callback;
    }
}
