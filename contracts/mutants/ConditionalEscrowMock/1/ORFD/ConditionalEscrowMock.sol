// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../payment/escrow/ConditionalEscrow.sol";

// mock class using ConditionalEscrow
contract ConditionalEscrowMock is ConditionalEscrow {
    mapping(address => bool) private _allowed;

    function setAllowed(address payee, bool allowed) public {
        _allowed[payee] = allowed;
    }

    
}
