// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IERC2981} from "../core/IERC2981.sol";

// N:B: Mock contract for testing purposes only
contract SimpleIERC2981 is ERC165, IERC2981 {

    mapping(uint256 => uint256) internal tokenIdToAmount;
    mapping(uint256 => address) internal tokenIdToReceiver;

    constructor(uint256[] memory tokenIds, address[] memory receivers, uint256[] memory amounts) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenIdToReceiver[tokenIds[i]] = receivers[i];
            tokenIdToAmount[tokenIds[i]] = amounts[i];
        }
    }

    

    

    function hasRoyalties(uint256 _tokenId) external override view returns (bool) {
        return tokenIdToReceiver[_tokenId] != address(0);
    }
}
