// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "../interfaces/IVaultManager.sol";
import "../interfaces/ITreasury.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockVaultManager {
    ITreasury public treasury;
    mapping(uint256 => Vault) public vaultData;
    mapping(uint256 => address) public ownerOf;
    uint256 public surplus;
    uint256 public badDebt;
    IAgToken public token;
    address public oracle = address(this);

    address public governor;
    address public collateral;
    address public stablecoin;
    uint256 public oracleValue;
    uint256 public interestAccumulator;
    uint256 public collateralFactor;
    uint256 public totalNormalizedDebt;

    constructor(address _treasury) {
        treasury = ITreasury(_treasury);
    }

    function accrueInterestToTreasury() public returns (uint256, uint256) {
        // Avoid the function to be view
        if (surplus >= badDebt) {
            token.mint(msg.sender, surplus - badDebt);
        }
        return (surplus, badDebt);
    }

    function read() public view returns (uint256) {
        return oracleValue;
    }

    function setParams(
        address _governor,
        address _collateral,
        address _stablecoin,
        uint256 _oracleValue,
        uint256 _interestAccumulator,
        uint256 _collateralFactor,
        uint256 _totalNormalizedDebt
    ) public {
        governor = _governor;
        collateral = _collateral;
        stablecoin = _stablecoin;
        interestAccumulator = _interestAccumulator;
        collateralFactor = _collateralFactor;
        totalNormalizedDebt = _totalNormalizedDebt;
        oracleValue = _oracleValue;
    }

    function setOwner(uint256 vaultID, address owner) public {
        ownerOf[vaultID] = owner;
    }

    function setVaultData(
        uint256 normalizedDebt,
        uint256 collateralAmount,
        uint256 vaultID
    ) public {
        vaultData[vaultID].normalizedDebt = normalizedDebt;
        vaultData[vaultID].collateralAmount = collateralAmount;
    }

    function isGovernor(address admin) public view returns (bool) {
        return admin == governor;
    }

    function setSurplusBadDebt(
        uint256 _surplus,
        uint256 _badDebt,
        IAgToken _token
    ) public {
        surplus = _surplus;
        badDebt = _badDebt;
        token = _token;
    }

    function getDebtOut(
        uint256 vaultID,
        uint256 amountStablecoins,
        uint256 senderBorrowFee
    ) public {}

    function setTreasury(address _treasury) public {
        treasury = ITreasury(_treasury);
    }

    function getVaultDebt(uint256 vaultID) public view returns (uint256) {
        vaultID;
        token;
        return 0;
    }

    function createVault(address toVault) external view returns (uint256) {
        toVault;
        token;
        return 0;
    }
}
