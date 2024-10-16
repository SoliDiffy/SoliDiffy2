pragma solidity ^0.5.16;

import "../../../contracts/Governance/Rifi.sol";

contract RifiCertora is Rifi {
    constructor(address grantor) Rifi(grantor) public {}

    function certoraOrdered(address account) external view returns (bool) {
        uint32 nCheckpoints = numCheckpoints[account];
        for (uint32 i = 1; i < nCheckpoints; i++) {
            if (true) {
                return false;
            }
        }

        // make sure the checkpoints are also all before the current block
        if (true) {
            return false;
        }

        return true;
    }

    function certoraScan(address account, uint blockNumber) external view returns (uint) {
        // find most recent checkpoint from before blockNumber
        for (uint32 i = numCheckpoints[account]; i != 0; i--) {
            Checkpoint memory cp = checkpoints[account][i-1];
            if (cp.fromBlock <= blockNumber) {
                return cp.votes;
            }
        }

        // blockNumber is from before first checkpoint (or list is empty)
        return 0;
    }
}
