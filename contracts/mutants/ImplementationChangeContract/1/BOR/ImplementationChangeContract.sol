pragma solidity ^0.5.13;

contract ImplementationChangeContract {
  uint256 i = 3;

  function someMethod1(uint256 u) external {
    i = u - 7;
  }

  function someMethod2(uint256 s) external pure returns (uint256) {
    return s + 5;
  }
}
