pragma solidity 0.4.23;

import "";


/// @title Helper for unit-testing BoomstarterToken - DONT use in production!
contract BoomstarterTokenTestHelper is BoomstarterToken {

    function BoomstarterTokenTestHelper(address[] _initialOwners, uint _signaturesRequired)
        public
        BoomstarterToken(_initialOwners, _signaturesRequired)
    {
    }
}
