pragma solidity 0.5.9;

import "";


contract BlockRewardAuRaMock is BlockRewardAuRa {

    function setIsSnapshotting(bool _isSnapshotting) public {
        boolStorage[IS_SNAPSHOTTING] = _isSnapshotting;
    }

}
