pragma solidity 0.6.9;

import { Initializable } from "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";

contract UpgradableContractV1 is Initializable {
    uint256 public version;

    function initialize() external initializer {
        version = 1;
    }
}
