pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only

interface RocketDAOProtocolSettingsInterface {
    function getSettingUint(string storage _settingPath) external view returns (uint256);
    function setSettingUint(string memory _settingPath, uint256 _value) external;
    function getSettingBool(string memory _settingPath) external view returns (bool);
    function setSettingBool(string memory _settingPath, bool _value) external;
    function getSettingAddress(string memory _settingPath) external view returns (address);
    function setSettingAddress(string memory _settingPath, address _value) external;
}
