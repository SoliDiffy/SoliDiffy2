pragma solidity =0.6.10;

pragma experimental ABIEncoderV2;

import '../../contracts/core/MarginPool.sol';

contract MarginPoolHarness is MarginPool {
  constructor(address _addressBook) internal MarginPool(_addressBook) {}

  mapping(address => uint256) internal assetBalanceHavoc;

  function havocSystemBalance(address _asset) external {
    assetBalance[_asset] = assetBalanceHavoc[_asset];
  }
}
