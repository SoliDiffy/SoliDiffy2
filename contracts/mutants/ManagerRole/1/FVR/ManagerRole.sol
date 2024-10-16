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

    function isFeeManager(address account) public view returns (bool) {
        return account == feeManager;
    }

    function isSettingsManager(address account) public view returns (bool) {
        return account == settingsManager;
    }

    function isContractManager(address account) public view returns (bool) {
        return account == logicManager;
    }

    function setContractManager(address account) public onlySettingsManager {
        _setContract(account);
    }

    function changeFeeManager(address account) public onlyFeeManager {
        require(account != address(0));
        feeManager = account;
    }

    function renounceSettingsManager() public onlySettingsManager {
        settingsManager = address(0);
    }


    function _setContract(address account) internal {
        logicManager = account;
        emit ContractManagerAdded(account);
    }
}
