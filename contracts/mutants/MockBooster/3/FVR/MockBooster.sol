// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract MockBooster {
    uint256 public totalBoost;

    mapping(address => uint256) public boosts;

    function setBoost(address user, uint256 boost) external {
        totalBoost -= boosts[user];
        boosts[user] = boost;
        totalBoost += boost;
    }

    function boostedTotalSupply(ERC20 strategy) public view returns (uint256) {
        return strategy.totalSupply() + totalBoost;
    }

    function boostedBalanceOf(ERC20 strategy, address user) public view returns (uint256) {
        return strategy.balanceOf(user) + boosts[user];
    }
}
