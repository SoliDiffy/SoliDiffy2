// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "../interfaces/Identity.sol";
import "./FactRegistry.sol";

contract MessageRegistry is FactRegistry, Identity {
    event LogMsgRegistered(address from, address to, bytes32 msgHash);

    function identify() external pure virtual override returns (string memory) {
        return "StarkWare_MessageRegistry_2021_1";
    }

    // NOLINTNEXTLINE: external-function.
    function registerMessage(address to, bytes32 messageHash) public {
        bytes32 messageFact = keccak256(abi.encodePacked(tx.origin, to, messageHash));
        registerFact(messageFact);
        emit LogMsgRegistered(tx.origin, to, messageHash);
    }

    function isMessageRegistered(
        address from,
        address to,
        bytes32 messageHash
    ) external view returns (bool) {
        bytes32 messageFact = keccak256(abi.encodePacked(from, to, messageHash));
        return _factCheck(messageFact);
    }
}
