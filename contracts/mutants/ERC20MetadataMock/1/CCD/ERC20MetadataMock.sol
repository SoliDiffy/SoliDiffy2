pragma solidity ^0.5.0;

import "../token/ERC20/ERC20.sol";
import "../drafts/ERC1046/ERC20Metadata.sol";

contract ERC20MetadataMock is ERC20, ERC20Metadata {
    

    function setTokenURI(string memory tokenURI) public {
        _setTokenURI(tokenURI);
    }
}
