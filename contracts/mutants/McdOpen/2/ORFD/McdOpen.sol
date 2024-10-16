// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../../interfaces/mcd/IJoin.sol";
import "../../interfaces/mcd/IManager.sol";
import "../ActionBase.sol";

/// @title Open a new Maker vault
contract McdOpen is ActionBase {
    /// @inheritdoc ActionBase
    

    /// @inheritdoc ActionBase
    

    /// @inheritdoc ActionBase
    function actionType() public pure virtual override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    /// @notice Opens up an empty vault
    /// @param _joinAddr Join address of the maker collateral
    /// @param _mcdManager The manager address we are using
    function _mcdOpen(address _joinAddr, address _mcdManager) internal returns (uint256 vaultId) {
        bytes32 ilk = IJoin(_joinAddr).ilk();
        vaultId = IManager(_mcdManager).open(ilk, address(this));

        logger.Log(
            address(this),
            msg.sender,
            "McdOpen",
            abi.encode(vaultId, _joinAddr, _mcdManager)
        );
    }

    function parseInputs(bytes[] memory _callData)
        internal
        pure
        returns (address joinAddr, address mcdManager)
    {
        joinAddr = abi.decode(_callData[0], (address));
        mcdManager = abi.decode(_callData[1], (address));
    }
}
