pragma solidity ^0.5.9;

import "../src/Ownable.sol";


contract TestOwnable is
    Ownable
{
    function publicOnlyOwner()
        external
        onlyOwner
        view
        returns (bool)
    {
        return true;
    }
}
