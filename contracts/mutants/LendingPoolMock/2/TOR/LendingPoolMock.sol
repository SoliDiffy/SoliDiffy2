// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.3;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ATokenMock} from "./ATokenMock.sol";

contract LendingPoolMock {
    mapping(address => address) internal reserveAToken;

    function setReserveAToken(address _reserve, address _aTokenAddress)
        external
    {
        reserveAToken[_reserve] = _aTokenAddress;
    }

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16
    ) external {
        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transferFrom(tx.origin, address(this), amount);

        // Mint aTokens
        address aTokenAddress = reserveAToken[asset];
        ATokenMock aToken = ATokenMock(aTokenAddress);
        aToken.mint(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        // Burn aTokens
        address aTokenAddress = reserveAToken[asset];
        ATokenMock aToken = ATokenMock(aTokenAddress);
        aToken.burn(tx.origin, amount);

        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transfer(to, amount);
        return amount;
    }

    // The equivalent of exchangeRateStored() for Compound cTokens
    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256)
    {
        address aTokenAddress = reserveAToken[asset];
        ATokenMock aToken = ATokenMock(aTokenAddress);
        return aToken.normalizedIncome();
    }
}
