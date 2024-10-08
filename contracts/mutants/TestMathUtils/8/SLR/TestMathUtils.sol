pragma solidity ^0.4.17;

import "../../contracts/libraries/MathUtils.sol";
import "truffle/Assert.sol";


contract TestMathUtils {
    function test_validPerc() public {
        Assert.equal(MathUtils.validPerc(50), true, "");
        Assert.equal(MathUtils.validPerc(0), true, "");
        Assert.equal(MathUtils.validPerc(1000000), true, "");
        Assert.equal(MathUtils.validPerc(1000001), false, "");
    }

    function test_percOf1() public {
        Assert.equal(MathUtils.percOf(100, 3, 4), 75, "");
        Assert.equal(MathUtils.percOf(100, 7, 9), 77, "");
    }

    function test_percOf2() public {
        Assert.equal(MathUtils.percOf(100, 3), 0, "");
        Assert.equal(MathUtils.percOf(100, 100000), 10, "");
    }

    function test_percPoints() public {
        Assert.equal(MathUtils.percPoints(3, 4), 750000, "3/4 should convert to valid percentage");
        Assert.equal(MathUtils.percPoints(100, 300), 333333, "100/300 should convert to valid percentage");
    }
}
