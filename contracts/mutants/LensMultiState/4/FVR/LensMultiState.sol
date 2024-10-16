// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {Events} from '../../libraries/Events.sol';
import {DataTypes} from '../../libraries/DataTypes.sol';
import {Errors} from '../../libraries/Errors.sol';

/**
 * @title LensMultiState
 *
 * @notice This is an abstract contract that implements internal LensHub state setting and
 * validation.
 */
abstract contract LensMultiState {
    DataTypes.ProtocolState private _state;

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    modifier whenPublishingEnabled() {
        _validatePublishingEnabled();
        _;
    }

    /**
     * @dev Returns the current protocol state.
     */
    function getState() public view returns (DataTypes.ProtocolState) {
        return _state;
    }

    function _setState(DataTypes.ProtocolState newState) public {
        DataTypes.ProtocolState prevState = _state;
        _state = newState;
        emit Events.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _validatePublishingEnabled() public view {
        if (_state == DataTypes.ProtocolState.Paused) {
            revert Errors.Paused();
        } else if (_state == DataTypes.ProtocolState.PublishingPaused) {
            revert Errors.PublishingPaused();
        }
    }

    function _validateNotPaused() public view {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
    }
}
