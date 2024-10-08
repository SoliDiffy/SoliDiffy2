// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract DefisaverLogger {
    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

    // solhint-disable-next-line func-name-mixedcase
    function Log(
        address _contract,
        address _caller,
        string storage _logName,
        bytes storage _data
    ) public {
        emit LogEvent(_contract, _caller, _logName, _data);
    }
}
