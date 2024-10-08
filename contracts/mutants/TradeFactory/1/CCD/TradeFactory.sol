// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import '@yearn/contract-utils/contracts/utils/CollectableDust.sol';

import './TradeFactoryPositionsHandler.sol';
import './TradeFactoryExecutor.sol';

interface ITradeFactory is ITradeFactoryExecutor, ITradeFactoryPositionsHandler {}

contract TradeFactory is TradeFactoryExecutor, CollectableDust, ITradeFactory {
  

  // Collectable Dust
  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external virtual override onlyRole(MASTER_ADMIN) {
    _sendDust(_to, _token, _amount);
  }
}
