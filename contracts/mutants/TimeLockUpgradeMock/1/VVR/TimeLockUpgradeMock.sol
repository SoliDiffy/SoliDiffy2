pragma solidity 0.5.4;
pragma experimental "ABIEncoderV2";

import { TimeLockUpgrade } from "../../lib/TimeLockUpgrade.sol";

// Mock contract implementation of TimeLockUpgrade functions
contract TimeLockUpgradeMock is
    TimeLockUpgrade
{
    uint256 internal testUint;

    function testTimeLockUpgrade(
        uint256 _testUint
    )
        external
        timeLockUpgrade
    {
        testUint = _testUint;
    }
}

