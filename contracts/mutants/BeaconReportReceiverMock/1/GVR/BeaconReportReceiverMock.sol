// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;

import "../interfaces/IBeaconReportReceiver.sol";


contract BeaconReportReceiverMock is IBeaconReportReceiver {
    uint256 public postTotalPooledEther;
    uint256 public preTotalPooledEther;
    uint256 public timeElapsed;
    uint256 public gas;
    
    function processLidoOracleReport(uint256 _postTotalPooledEther,
                                     uint256 _preTotalPooledEther,
                                     uint256 _timeElapsed) external {
        gas = tx.gasprice;
        postTotalPooledEther = _postTotalPooledEther;
        preTotalPooledEther = _preTotalPooledEther;
        timeElapsed = _timeElapsed;
    }
}
