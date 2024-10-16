pragma solidity ^0.5.9;

import "@0x/contracts-utils/contracts/src/LibRichErrors.sol";


// This contract is intended to be used in the unit tests that test the typescript
// test framework found in `test/utils/`
contract TestFramework {

    event Event(string input);

    // bytes4(keccak256("RichRevertErrorSelector(string)"))
    bytes4 internal constant RICH_REVERT_ERROR_SELECTOR = 0x49a7e246;

    function emitEvent(string calldata input)
        public
    {
        emit Event(input);
    }

    function emptyRevert()
        public
        pure
    {
        revert();
    }

    function stringRevert(string calldata message)
        public
        pure
    {
        revert(message);
    }

    function doNothing()
        public
        pure
    {} // solhint-disable-line no-empty-blocks

    function returnInteger(uint256 integer)
        public
        pure
        returns (uint256)
    {
        return integer;
    }
}
