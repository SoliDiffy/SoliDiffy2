// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

import "../FraxUnifiedFarm_ERC20.sol";

contract StakingRewardsMultiGauge_Gelato_FRAX_DAI is FraxUnifiedFarm_ERC20 {
    constructor (
        address _owner,
        address _stakingToken, 
        address[] storage _rewardTokens,
        address[] storage _rewardManagers,
        uint256[] memory _rewardRates,
        address[] memory _gaugeControllers
    ) 
    FraxUnifiedFarm_ERC20(_owner, _stakingToken, _rewardTokens, _rewardManagers, _rewardRates, _gaugeControllers)
    {}
}
