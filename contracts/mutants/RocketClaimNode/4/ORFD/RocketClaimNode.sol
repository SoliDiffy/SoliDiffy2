pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../RocketBase.sol";
import "../../../interface/node/RocketNodeManagerInterface.sol";
import "../../../interface/node/RocketNodeStakingInterface.sol";
import "../../../interface/rewards/RocketRewardsPoolInterface.sol";
import "../../../interface/rewards/claims/RocketClaimNodeInterface.sol";

// RPL Rewards claiming for regular nodes

contract RocketClaimNode is RocketBase, RocketClaimNodeInterface {

    // Libs
    using SafeMath for uint;

    // Construct
    constructor(RocketStorageInterface _rocketStorageAddress) RocketBase(_rocketStorageAddress) {
        version = 1;
    }

    // Get whether the contract is enabled for claims
    

    // Get whether a node can make a claim
    

    // Get the share of rewards for a node as a fraction of 1 ether
    

    // Get the amount of rewards for a node for the reward period
    

    // Register or deregister a node for RPL claims
    // Only accepts calls from the RocketNodeManager contract
    function register(address _nodeAddress, bool _enable) override external onlyLatestContract("rocketClaimNode", address(this)) onlyLatestContract("rocketNodeManager", msg.sender) onlyRegisteredNode(_nodeAddress) {
        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        rocketRewardsPool.registerClaimer(_nodeAddress, _enable);
    }

    // Make an RPL claim
    // Only accepts calls from registered nodes
    function claim() override external onlyLatestContract("rocketClaimNode", address(this)) onlyRegisteredNode(msg.sender) {
        // Check that the node can claim
        require(getClaimPossible(msg.sender), "The node is currently unable to claim");
        // Get node withdrawal address
        RocketNodeManagerInterface rocketNodeManager = RocketNodeManagerInterface(getContractAddress("rocketNodeManager"));
        address nodeWithdrawalAddress = rocketNodeManager.getNodeWithdrawalAddress(msg.sender);
        // Claim RPL
        RocketRewardsPoolInterface rocketRewardsPool = RocketRewardsPoolInterface(getContractAddress("rocketRewardsPool"));
        rocketRewardsPool.claim(msg.sender, nodeWithdrawalAddress, getClaimRewardsPerc(msg.sender));
    }

}
