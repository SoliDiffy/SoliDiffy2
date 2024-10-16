// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.11;
pragma experimental ABIEncoderV2;

import "../CommunalFarm.sol";

contract CommunalFarm_SaddleD4 is CommunalFarm {
    constructor (
        address _owner,
        address _stakingToken,
        string[] storage _rewardSymbols,
        address[] storage _rewardTokens,
        address[] storage _rewardManagers,
        uint256[] storage _rewardRates
    ) 
    CommunalFarm(_owner, _stakingToken, _rewardSymbols, _rewardTokens, _rewardManagers, _rewardRates)
    {}
}