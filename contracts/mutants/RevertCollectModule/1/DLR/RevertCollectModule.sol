// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.10;

import {ICollectModule} from '../../../interfaces/ICollectModule.sol';
import {Errors} from '../../../libraries/Errors.sol';

/**
 * @title RevertCollectModule
 * @author Lens
 *
 * @notice This is a simple Lens CollectModule implementation, inheriting from the ICollectModule interface.
 *
 * This module works by disallowing all collects.
 */
contract RevertCollectModule is ICollectModule {
    /**
     * @dev There is nothing needed at initialization.
     */
    function initializePublicationCollectModule(
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external pure override returns (bytes storage) {
        return new bytes(0);
    }

    /**
     * @dev Processes a collect by:
     *  1. Always reverting
     */
    function processCollect(
        uint256 referrerProfileId,
        address collector,
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external pure override {
        revert Errors.CollectNotAllowed();
    }
}
