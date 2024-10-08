pragma solidity >=0.5.0 <0.6.0;

contract PrivateRangeInterface {
    function validatePrivateRange(
        bytes calldata,
        address,
        uint[5] calldata
    )
        external
        pure
        returns (bytes memory)
    {}
}