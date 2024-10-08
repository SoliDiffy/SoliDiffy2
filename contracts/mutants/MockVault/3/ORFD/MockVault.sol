// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import { VaultCore } from "../vault/VaultCore.sol";
import { StableMath } from "../utils/StableMath.sol";
import { VaultInitializer } from "../vault/VaultInitializer.sol";
import "../utils/Helpers.sol";

contract MockVault is VaultCore, VaultInitializer {
    using StableMath for uint256;

    uint256 storedTotalValue;

    function setTotalValue(uint256 _value) public {
        storedTotalValue = _value;
    }

    

    

    

    function setMaxSupplyDiff(uint256 _maxSupplyDiff) external onlyGovernor {
        maxSupplyDiff = _maxSupplyDiff;
    }
}
