// SPDX-License-Identifier: MIT

pragma solidity >=0.6.11;

contract Migrations {
    address public owner;
    uint256 public last_completed_migration;

    constructor() internal {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }
}
