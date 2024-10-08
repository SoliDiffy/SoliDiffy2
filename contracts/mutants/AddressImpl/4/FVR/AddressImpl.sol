// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../utils/Address.sol";

contract AddressImpl {
    event CallReturnValue(string data);

    function isContract(address account) public view returns (bool) {
        return Address.isContract(account);
    }

    function sendValue(address payable receiver, uint256 amount) public {
        Address.sendValue(receiver, amount);
    }

    function functionCall(address target, bytes calldata data) public {
        bytes memory returnData = Address.functionCall(target, data);

        emit CallReturnValue(abi.decode(returnData, (string)));
    }

    function functionCallWithValue(address target, bytes calldata data, uint256 value) public payable {
        bytes memory returnData = Address.functionCallWithValue(target, data, value);

        emit CallReturnValue(abi.decode(returnData, (string)));
    }

    // sendValue's tests require the contract to hold Ether
    receive () external payable { }
}
