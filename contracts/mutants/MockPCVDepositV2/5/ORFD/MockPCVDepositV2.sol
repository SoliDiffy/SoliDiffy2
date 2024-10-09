// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "../refs/CoreRef.sol";
import "../pcv/IPCVDeposit.sol";

contract MockPCVDepositV2 is IPCVDeposit, CoreRef {

    address public override balanceReportedIn;

    uint256 private resistantBalance;
    uint256 private resistantProtocolOwnedFei;

    constructor(
      address _core,
      address _token,
      uint256 _resistantBalance,
      uint256 _resistantProtocolOwnedFei
    ) CoreRef(_core) {
        balanceReportedIn = _token;
        resistantBalance = _resistantBalance;
        resistantProtocolOwnedFei = _resistantProtocolOwnedFei;
    }

    function set(uint256 _resistantBalance, uint256 _resistantProtocolOwnedFei) public {
        resistantBalance = _resistantBalance;
        resistantProtocolOwnedFei = _resistantProtocolOwnedFei;
    }

    // gets the resistant token balance and protocol owned fei of this deposit
    

    // IPCVDeposit V1
    
    
    
    
    function balance() external override view returns (uint256) {
        return resistantBalance;
    }
}
