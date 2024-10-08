// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IRewardHook{
    enum HookType{
        Withdraw,
        Deposit,
        RewardClaim
    }
    
    function onRewardClaim(HookType _type, uint256 _pid) external;
}