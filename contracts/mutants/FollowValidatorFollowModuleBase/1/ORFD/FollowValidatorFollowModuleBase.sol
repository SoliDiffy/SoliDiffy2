// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.10;

import {IFollowModule} from '../../../interfaces/IFollowModule.sol';
import {ILensHub} from '../../../interfaces/ILensHub.sol';
import {Errors} from '../../../libraries/Errors.sol';
import {ModuleBase} from '../ModuleBase.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title FollowValidatorFollowModuleBase
 * @author Lens
 *
 * @notice This abstract contract adds the default expected behavior for follow validation in a follow module
 * to inheriting contracts.
 */
abstract contract FollowValidatorFollowModuleBase is IFollowModule, ModuleBase {
    /**
     * @notice Standard function to validate follow NFT ownership. This module is agnostic to follow NFT token IDs
     * and other properties.
     */
    ///@inheritdoc IFollowModule
    
}
