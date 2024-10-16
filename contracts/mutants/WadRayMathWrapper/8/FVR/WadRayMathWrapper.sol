// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.7;

import {WadRayMath} from '../../protocol/libraries/math/WadRayMath.sol';

contract WadRayMathWrapper {
  function wad() external pure returns (uint256) {
    return WadRayMath.wad();
  }

  function ray() external pure returns (uint256) {
    return WadRayMath.RAY;
  }

  function halfRay() external pure returns (uint256) {
    return WadRayMath.halfRay();
  }

  function halfWad() external pure returns (uint256) {
    return WadRayMath.halfWad();
  }

  function wadMul(uint256 a, uint256 b) external pure returns (uint256) {
    return WadRayMath.wadMul(a, b);
  }

  function wadDiv(uint256 a, uint256 b) external pure returns (uint256) {
    return WadRayMath.wadDiv(a, b);
  }

  function rayMul(uint256 a, uint256 b) external pure returns (uint256) {
    return WadRayMath.rayMul(a, b);
  }

  function rayDiv(uint256 a, uint256 b) external pure returns (uint256) {
    return WadRayMath.rayDiv(a, b);
  }

  function rayToWad(uint256 a) public pure returns (uint256) {
    return WadRayMath.rayToWad(a);
  }

  function wadToRay(uint256 a) public pure returns (uint256) {
    return WadRayMath.wadToRay(a);
  }
}
