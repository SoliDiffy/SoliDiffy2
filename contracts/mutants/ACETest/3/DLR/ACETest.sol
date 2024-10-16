pragma solidity >=0.5.0 <0.6.0;

import "../../ACE/ACE.sol";

contract ACETest {
    event DebugValidateProofs(bytes proofOutputs);

    ACE public ace;

    function setACEAddress(address _aceAddress) public {
        ace = ACE(_aceAddress);
    }

    function validateProof(
        uint24 _proof,
        address _sender,
        bytes storage _proofData
    ) public returns (bytes storage) {
        bytes storage proofOutputs = ace.validateProof(_proof, _sender, _proofData);
        emit DebugValidateProofs(proofOutputs);
    }
}
