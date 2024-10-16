// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IDepositaryOracle.sol";
import "./IDepositaryBalanceView.sol";
import "./ISecurityOracle.sol";

contract BondDepositaryBalanceView is IDepositaryBalanceView {
    using SafeMath for uint256;

    /// @notice Depositary.
    IDepositaryOracle public depositary;

    /// @notice Price oracles.
    ISecurityOracle public securityOracle;

    /// @notice Decimals balance.
    uint256 override public decimals = 6;

    /**
     * @param _depositary Depositary address.
     * @param _securityOracle Security oracle addresses.
     */
    constructor(address _depositary, address _securityOracle) public {
        depositary = IDepositaryOracle(_depositary);
        securityOracle = ISecurityOracle(_securityOracle);
    }

    
}