pragma solidity ^0.8.0;

contract MockContract {
    address public lastReceiver;

    function _transfer(address payable _reciver, uint amount) external payable {
        _reciver.transfer(amount);

        lastReceiver = _reciver;
    }
}