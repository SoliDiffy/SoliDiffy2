/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;

import "../src/interfaces/IStructs.sol";
import "./TestStakingNoWETH.sol";


contract TestDelegatorRewards is
    TestStakingNoWETH
{
    event FinalizePool(
        bytes32 poolId,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    );

    struct UnfinalizedPoolReward {
        uint256 operatorReward;
        uint256 membersReward;
        uint256 membersStake;
    }

    constructor() internal {
        _addAuthorizedAddress(msg.sender);
        init();
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    mapping (uint256 => mapping (bytes32 => UnfinalizedPoolReward)) private
        unfinalizedPoolRewardsByEpoch;

    /// @dev Set unfinalized rewards for a pool in the current epoch.
    function setUnfinalizedPoolReward(
        bytes32 poolId,
        address payable operatorAddress,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    )
        public
    {
        unfinalizedPoolRewardsByEpoch[currentEpoch][poolId] = UnfinalizedPoolReward({
            operatorReward: operatorReward,
            membersReward: membersReward,
            membersStake: membersStake
        });
        // Lazily initialize this pool.
        _poolById[poolId].operator = operatorAddress;
        _setOperatorShare(poolId, operatorReward, membersReward);
    }

    /// @dev Expose/wrap `_syncPoolRewards`.
    function syncPoolRewards(
        bytes32 poolId,
        address payable operatorAddress,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    )
        public
    {
        // Lazily initialize this pool.
        _poolById[poolId].operator = operatorAddress;
        _setOperatorShare(poolId, operatorReward, membersReward);

        _syncPoolRewards(
            poolId,
            operatorReward + membersReward,
            membersStake
        );
    }

    /// @dev Advance the epoch.
    function advanceEpoch() public {
        currentEpoch += 1;
    }

    /// @dev Create and delegate stake to the current epoch.
    ///      Only used to test purportedly unreachable states.
    ///      Also withdraws pending rewards.
    function delegateStakeNow(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        public
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        _stake.currentEpochBalance += uint96(stake);
        _stake.nextEpochBalance += uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
    }

    /// @dev Create and delegate stake that will occur in the next epoch
    ///      (normal behavior).
    ///      Also withdraws pending rewards.
    function delegateStake(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        public
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        if (_stake.currentEpoch < currentEpoch) {
            _stake.currentEpochBalance = _stake.nextEpochBalance;
        }
        _stake.nextEpochBalance += uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
    }

    /// @dev Clear stake that will occur in the next epoch
    ///      (normal behavior).
    ///      Also withdraws pending rewards.
    function undelegateStake(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        public
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        if (_stake.currentEpoch < currentEpoch) {
            _stake.currentEpochBalance = _stake.nextEpochBalance;
        }
        _stake.nextEpochBalance -= uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
    }

    // solhint-disable no-simple-event-func-name
    /// @dev Overridden to realize `unfinalizedPoolRewardsByEpoch` in
    ///      the current epoch and emit a event,
    function finalizePool(bytes32 poolId)
        public
    {
        UnfinalizedPoolReward memory reward = unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];
        delete unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];

        _setOperatorShare(poolId, reward.operatorReward, reward.membersReward);

        uint256 totalRewards = reward.operatorReward + reward.membersReward;
        uint256 membersStake = reward.membersStake;
        (uint256 operatorReward, uint256 membersReward) =
            _syncPoolRewards(poolId, totalRewards, membersStake);
        emit FinalizePool(poolId, operatorReward, membersReward, membersStake);
    }

    /// @dev Overridden to use unfinalizedPoolRewardsByEpoch.
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        public
        view
        returns (
            uint256 totalReward,
            uint256 membersStake
        )
    {
        UnfinalizedPoolReward storage reward = unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];
        totalReward = reward.operatorReward + reward.membersReward;
        membersStake = reward.membersStake;
    }

    /// @dev Set the operator share of a pool based on reward ratios.
    function _setOperatorShare(
        bytes32 poolId,
        uint256 operatorReward,
        uint256 membersReward
    )
        public
    {
        uint32 operatorShare = 0;
        uint256 totalReward = operatorReward + membersReward;
        if (totalReward != 0) {
            operatorShare = uint32(
                operatorReward * PPM_DENOMINATOR / totalReward
            );
        }
        _poolById[poolId].operatorShare = operatorShare;
    }

}
