// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/StringsUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

contract StringsMockUpgradeable is Initializable {
    function __StringsMock_init() public onlyInitializing {
    }

    function __StringsMock_init_unchained() public onlyInitializing {
    }
    function fromUint256(uint256 value) external pure returns (string memory) {
        return StringsUpgradeable.toString(value);
    }

    function fromUint256Hex(uint256 value) external pure returns (string memory) {
        return StringsUpgradeable.toHexString(value);
    }

    function fromUint256HexFixed(uint256 value, uint256 length) external pure returns (string memory) {
        return StringsUpgradeable.toHexString(value, length);
    }

    function fromAddressHexFixed(address addr) external pure returns (string memory) {
        return StringsUpgradeable.toHexString(addr);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
