pragma solidity ^0.4.0;

import "./owned.sol";

contract mortal is owned {
    function kill() external {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}
