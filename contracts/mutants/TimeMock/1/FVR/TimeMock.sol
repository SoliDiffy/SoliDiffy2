pragma solidity ^0.4.23;

library TimeMock {

  function getTime() public view returns (uint time) {
    assembly { time := sload(2) }
    time = time == 0 ? now : time;
  }
}
