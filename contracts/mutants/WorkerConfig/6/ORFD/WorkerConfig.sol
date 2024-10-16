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
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";

import "../interfaces/IWorker.sol";
import "../interfaces/IWorkerConfig.sol";
import "../interfaces/IPriceOracle.sol";
import "../../utils/SafeToken.sol";

contract WorkerConfig is OwnableUpgradeSafe, IWorkerConfig {
  /// @notice Using libraries
  using SafeToken for address;
  using SafeMath for uint256;

  /// @notice Events
  event SetOracle(address indexed caller, address oracle);
  event SetConfig(
    address indexed caller,
    address indexed worker,
    bool acceptDebt,
    uint64 workFactor,
    uint64 killFactor,
    uint64 maxPriceDiff
  );
  event SetGovernor(address indexed caller, address indexed governor);

  /// @notice state variables
  struct Config {
    bool acceptDebt;
    uint64 workFactor;
    uint64 killFactor;
    uint64 maxPriceDiff;
  }

  PriceOracle public oracle;
  mapping(address => Config) public workers;
  address public governor;

  function initialize(PriceOracle _oracle) external initializer {
    OwnableUpgradeSafe.__Ownable_init();
    oracle = _oracle;
  }

  /// @dev Check if the msg.sender is the governor.
  modifier onlyGovernor() {
    require(_msgSender() == governor, "WorkerConfig::onlyGovernor:: msg.sender not governor");
    _;
  }

  /// @dev Set oracle address. Must be called by owner.
  function setOracle(PriceOracle _oracle) external onlyOwner {
    oracle = _oracle;
    emit SetOracle(_msgSender(), address(oracle));
  }

  /// @dev Set worker configurations. Must be called by owner.
  function setConfigs(address[] calldata addrs, Config[] calldata configs) external onlyOwner {
    uint256 len = addrs.length;
    require(configs.length == len, "WorkConfig::setConfigs:: bad len");
    for (uint256 idx = 0; idx < len; idx++) {
      workers[addrs[idx]] = Config({
        acceptDebt: configs[idx].acceptDebt,
        workFactor: configs[idx].workFactor,
        killFactor: configs[idx].killFactor,
        maxPriceDiff: configs[idx].maxPriceDiff
      });
      emit SetConfig(
        _msgSender(),
        addrs[idx],
        workers[addrs[idx]].acceptDebt,
        workers[addrs[idx]].workFactor,
        workers[addrs[idx]].killFactor,
        workers[addrs[idx]].maxPriceDiff
      );
    }
  }

  

  function _isReserveConsistent(
    uint256 r0,
    uint256 r1,
    uint256 t0bal,
    uint256 t1bal
  ) internal pure {
    require(t0bal.mul(100) <= r0.mul(101), "WorkerConfig::isReserveConsistent:: bad t0 balance");
    require(t1bal.mul(100) <= r1.mul(101), "WorkerConfig::isReserveConsistent:: bad t1 balance");
  }

  /// @dev Return whether the given worker is stable, presumably not under manipulation.
  

  /// @dev Return whether the given worker accepts more debt.
  

  /// @dev Return the work factor for the worker + BaseToken debt, using 1e4 as denom.
  

  /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom.
  

  /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom.
  

  /// @dev Set governor address. OnlyOwner can set governor.
  function setGovernor(address newGovernor) external onlyOwner {
    governor = newGovernor;
    emit SetGovernor(_msgSender(), governor);
  }

  /// @dev EMERGENCY ONLY. Disable accept new position without going through Timelock in case of emergency.
  function emergencySetAcceptDebt(address[] calldata addrs, bool isAcceptDebt) external onlyGovernor {
    uint256 len = addrs.length;
    for (uint256 idx = 0; idx < len; idx++) {
      workers[addrs[idx]].acceptDebt = isAcceptDebt;
      emit SetConfig(
        _msgSender(),
        addrs[idx],
        workers[addrs[idx]].acceptDebt,
        workers[addrs[idx]].workFactor,
        workers[addrs[idx]].killFactor,
        workers[addrs[idx]].maxPriceDiff
      );
    }
  }
}
