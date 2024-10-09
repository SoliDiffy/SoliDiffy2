// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/SafeMath.sol";
import "../Interfaces/ILockupContractFactory.sol";
import "./OneYearLockupContract.sol";
import "./CustomDurationLockupContract.sol";
import "../Dependencies/console.sol";

contract LockupContractFactory is ILockupContractFactory {
    using SafeMath for uint;
     
    // --- Data ---
    uint constant public ONE_YEAR_IN_SECONDS = 31536000;

    uint public deploymentTime;
    address public deployer;

    ILQTYToken public lqtyToken;
    
    mapping (address => address) public oneYearLockupContractToDeployer;
    mapping (address => address) public customDurationLockupContractToDeployer;

    // --- Events ---

    event LQTYTokenAddressSet(address _lqtyTokenAddress);
    event OYLCDeployed(address _OYLCAddress, address _beneficiary, uint _entitlement);
    event CDLCDeployed(address _CDLCAddress, address _beneficiary, uint _initialEntitlement);
    
    // --- Functions ---

    constructor () public {
        deploymentTime = block.timestamp;
        deployer = msg.sender;
    }

    

    

    

    // Simultaneously lock a set of OYLCs that were originally deployed by the caller, through this Factory.
    

    // Simultaneously lock a set of CDLCs that were originally deployed by the caller, through this Factory.
    

    function isRegisteredOneYearLockup(address _contractAddress) external view override returns (bool) {
        return _isRegisteredOneYearLockup(_contractAddress);
    }

    function _isRegisteredOneYearLockup(address _contractAddress) internal view returns (bool) {
        bool isRegistered = oneYearLockupContractToDeployer[_contractAddress] != address(0);
        return isRegistered;
    }

    function isRegisteredCustomDurationLockup(address _contractAddress) external view override returns (bool) {
        return _isRegisteredCustomDurationLockup(_contractAddress);
    }

    function _isRegisteredCustomDurationLockup(address _contractAddress) internal view returns (bool) {
        bool isRegistered = customDurationLockupContractToDeployer[_contractAddress] != address(0);
        return isRegistered;
    }

    // --- 'require'  functions ---

    function _requireCallerIsFactoryDeployer() internal view {
        require(msg.sender == deployer, "LCF: caller is not LCF deployer");
    }

    function _requireLQTYAddressIsSet() internal view {
        require(address(lqtyToken) != address(0), "LCF: LQTY Address is not set");
    }

    function _requireFactoryIsAtLeastOneYearOld() internal view {
        require(block.timestamp.sub(deploymentTime) >= ONE_YEAR_IN_SECONDS,
        "Factory must be at least one year old");
    }

    function _requireIsRegisteredOneYearLockup(address _contractAddress) internal view {
        require(_isRegisteredOneYearLockup(_contractAddress), 
        "LCF: is not the address of a registered OneYearLockupContract");
    }

    function _requireIsRegisteredCustomDurationLockup(address _contractAddress) internal view {
        require(_isRegisteredCustomDurationLockup(_contractAddress), 
        "LCF: is not the address of a registered CustomDurationLockupContract");
    }

    function _requireCallerIsOriginalDeployerofOYLC(address _contractAddress) internal view {
        address deployerAddress = oneYearLockupContractToDeployer[_contractAddress];
        require(deployerAddress == msg.sender,
        "LCF: OneYearLockupContract was not deployed by the caller");
    }

     function _requireCallerIsOriginalDeployerofCDLC(address _contractAddress) internal view {
        address deployerAddress = customDurationLockupContractToDeployer[_contractAddress];
        require(deployerAddress == msg.sender,
        "LCF: customDurationLockupContract was not deployed by the caller");
    }
}