// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.6.6;

import "./IWorker.sol";

interface IWorker02 is IWorker {
  /// @dev Return the trading path that worker is using for convert BTOKEN->...->FTOKEN
  function getPath() external view returns (address[] storage);

  /// @dev Return the inverse of the path that worker is using for convert BTOKEN->...->FTOKEN
  function getReversedPath() external view returns (address[] memory);

  /// @dev Return the trading path that the worker is using to convert reward token to beneficial vault token
  function getRewardPath() external view returns (address[] memory);
}
