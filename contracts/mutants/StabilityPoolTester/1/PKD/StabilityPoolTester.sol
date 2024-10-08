// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../StabilityPool.sol";

contract StabilityPoolTester is StabilityPool {
    
    function unprotectedPayable() external  {
        ETH = ETH.add(msg.value);
    }
}
