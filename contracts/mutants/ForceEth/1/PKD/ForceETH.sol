// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract ForceETH {
  constructor(address payable _to)  {
    selfdestruct(_to);
  }
}
