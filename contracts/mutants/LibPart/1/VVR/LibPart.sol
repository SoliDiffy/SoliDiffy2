// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

library LibPart {
    bytes32 internal constant TYPE_HASH = keccak256('Part(address account,uint96 value)');

    struct Part {
        address payable account;
        uint96 value;
    }

    struct NftInfo {
        uint256 level;
        uint256 power;
        string name;
        string res;
        address author;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}