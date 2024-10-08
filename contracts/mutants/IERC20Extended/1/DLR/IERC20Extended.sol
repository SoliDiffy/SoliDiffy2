// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Extended {
  function symbol() external view returns (string storage);

  function decimals() external view returns (uint8);
}
