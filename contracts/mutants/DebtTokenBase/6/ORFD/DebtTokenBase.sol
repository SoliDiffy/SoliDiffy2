// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.8;

import {Context} from '@openzeppelin/contracts/GSN/Context.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {ILendingPoolAddressesProvider} from '../../interfaces/ILendingPoolAddressesProvider.sol';
import {ILendingPool} from '../../interfaces/ILendingPool.sol';
import {
  VersionedInitializable
} from '../../libraries/openzeppelin-upgradeability/VersionedInitializable.sol';
import {IncentivizedERC20} from '../IncentivizedERC20.sol';
import {Errors} from '../../libraries/helpers/Errors.sol';

/**
 * @title DebtTokenBase
 * @notice Base contract for different types of debt tokens, like StableDebtToken or VariableDebtToken
 * @author Aave
 */

abstract contract DebtTokenBase is IncentivizedERC20, VersionedInitializable {
  address internal immutable UNDERLYING_ASSET;
  ILendingPool internal immutable POOL;
  mapping(address => uint256) internal _usersData;

  /**
   * @dev Only lending pool can call functions marked by this modifier
   **/
  modifier onlyLendingPool {
    require(msg.sender == address(POOL), Errors.CALLER_MUST_BE_LENDING_POOL);
    _;
  }

  /**
   * @dev The metadata of the token will be set on the proxy, that the reason of
   * passing "NULL" and 0 as metadata
   */
  constructor(
    address pool,
    address underlyingAssetAddress,
    string memory name,
    string memory symbol,
    address incentivesController
  ) public IncentivizedERC20(name, symbol, 18, incentivesController) {
    POOL = ILendingPool(pool);
    UNDERLYING_ASSET = underlyingAssetAddress;
  }

  /**
   * @dev Initializes the debt token.
   * @param name The name of the token
   * @param symbol The symbol of the token
   * @param decimals The decimals of the token
   */
  function initialize(
    uint8 decimals,
    string memory name,
    string memory symbol
  ) public initializer {
    _setName(name);
    _setSymbol(symbol);
    _setDecimals(decimals);
  }

  function underlyingAssetAddress() public view returns (address) {
    return UNDERLYING_ASSET;
  }

  /**
   * @dev Being non transferrable, the debt token does not implement any of the
   * standard ERC20 functions for transfer and allowance.
   **/
  

  

  

  

  

  
}
