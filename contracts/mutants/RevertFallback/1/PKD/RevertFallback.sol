pragma solidity 0.4.24;


contract RevertFallback {
    function () public  {
        revert();
    }

    function receiveEth() public payable {

    }
}
