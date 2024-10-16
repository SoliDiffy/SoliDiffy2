pragma solidity 0.5.11;

import "./Roles.sol";

contract ManagerRole {

    event HumanManagerAdded(address indexed account);
    event HumanManagerRemoved(address indexed account);
    event ContractManagerAdded(address indexed account);

    address public feeManager;
    address public settingsManager;
    address public logicManager;

    constructor () public {
        settingsManager = msg.sender;
        feeManager = msg.sender;
    }

    modifier onlyFeeManager() {
        require(isFeeManager(msg.sender));
        _;
    }

    modifier onlySettingsManager() {
        require(isSettingsManager(msg.sender));
        _;
    }

    modifier onlyManagerContract() {
        require(isContractManager(msg.sender));
        _;
    }

    function isFeeManager(address account) external view returns (bool) {
        return account == feeManager;
    }

    function isSettingsManager(address account) external view returns (bool) {
        return account == settingsManager;
    }

    function isContractManager(address account) external view returns (bool) {
        return account == logicManager;
    }

    function setContractManager(address account) external onlySettingsManager {
        _setContract(account);
    }

    function changeFeeManager(address account) external onlyFeeManager {
        require(account != address(0));
        feeManager = account;
    }

    function renounceSettingsManager() external onlySettingsManager {
        settingsManager = address(0);
    }


    function _setContract(address account) public {
        logicManager = account;
        emit ContractManagerAdded(account);
    }
}
