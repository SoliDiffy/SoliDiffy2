// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.6.0;

import "../implementation/Withdrawable.sol";

// WithdrawableTest is derived from the abstract contract Withdrawable for testing purposes.
contract WithdrawableTest is Withdrawable {
    enum Roles { Governance, Withdraw }

    // solhint-disable-next-line no-empty-blocks
    constructor() public {
        _createExclusiveRole(uint8(Roles.Governance), uint8(Roles.Governance), msg.sender);
        _createWithdrawRole(uint8(Roles.Withdraw), uint8(Roles.Governance), msg.sender);
    }

    function pay() external payable {
        require(msg.value > 0);
    }

    function setInternalWithdrawRole(uint256 setRoleId) public {
        _setWithdrawRole(setRoleId);
    }
}
