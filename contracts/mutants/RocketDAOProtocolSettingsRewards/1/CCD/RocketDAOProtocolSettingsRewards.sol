pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

import "./RocketDAOProtocolSettings.sol";
import "../../../../interface/dao/protocol/settings/RocketDAOProtocolSettingsRewardsInterface.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

// Settings in RP which the DAO will have full control over
contract RocketDAOProtocolSettingsRewards is RocketDAOProtocolSettings, RocketDAOProtocolSettingsRewardsInterface {

    using SafeMath for uint;

    // Construct
    


    /*** Settings ****************/

    // Set a new claimer for the rpl rewards, must specify a unique contract name that will be claiming from and a percentage of the rewards
    function setSettingRewardsClaimer(string memory _contractName, uint256 _perc) override public onlyDAOProtocolProposal {
        // Get the total perc set, can't be more than 100
        uint256 percTotal = getRewardsClaimersPercTotal();
        // If this group already exists, it will update the perc
        uint256 percTotalUpdate = percTotal.add(_perc).sub(getRewardsClaimerPerc(_contractName));
        // Can't be more than a total claim amount of 100%
        require(percTotalUpdate <= 1 ether, "Claimers cannot total more than 100%");
        // Update the total
        setUint(keccak256(abi.encodePacked(settingNameSpace,"rewards.claims", "group.totalPerc")), percTotalUpdate);
        // Update/Add the claimer amount
        setUint(keccak256(abi.encodePacked(settingNameSpace, "rewards.claims", "group.amount", _contractName)), _perc);
        // Set the time it was updated at
        setUint(keccak256(abi.encodePacked(settingNameSpace, "rewards.claims", "group.amount.updated.time", _contractName)), block.timestamp);
    }



    /*** RPL Claims ***********************************************/


    // RPL Rewards Claimers (own namespace to prevent DAO setting voting to overwrite them)

    // Get the perc amount that this rewards contract get claim
    function getRewardsClaimerPerc(string memory _contractName) override public view returns (uint256) {
        return getUint(keccak256(abi.encodePacked(settingNameSpace, "rewards.claims", "group.amount", _contractName)));
    } 

    // Get the time of when the claim perc was last updated
    function getRewardsClaimerPercTimeUpdated(string memory _contractName) override external view returns (uint256) {
        return getUint(keccak256(abi.encodePacked(settingNameSpace, "rewards.claims", "group.amount.updated.time", _contractName)));
    } 

    // Get the perc amount total for all claimers (remaining goes to DAO)
    function getRewardsClaimersPercTotal() override public view returns (uint256) {
        return getUint(keccak256(abi.encodePacked(settingNameSpace, "rewards.claims", "group.totalPerc")));
    }


    // RPL Rewards General Settings

    // The period over which claims can be made
    function getRewardsClaimIntervalTime() override external view returns (uint256) {
        return getSettingUint("rpl.rewards.claim.period.time");
    }

}
