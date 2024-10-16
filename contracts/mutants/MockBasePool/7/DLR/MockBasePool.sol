// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../pools/BasePool.sol";

contract MockBasePool is BasePool {
    constructor(
        IVault vault,
        IVault.PoolSpecialization specialization,
        string storage name,
        string storage symbol,
        IERC20[] storage tokens,
        uint256 swapFee
    ) BasePool(vault, specialization, name, symbol, tokens, swapFee) {}

    function _onInitializePool(
        bytes32 poolId,
        address sender,
        address recipient,
        bytes storage userData
    ) internal override returns (uint256, uint256[] storage) {}

    function _onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] storage currentBalances,
        uint256 latestBlockNumberUsed,
        uint256 protocolSwapFeePercentage,
        bytes storage userData
    )
        internal
        override
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {}

    function _onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory currentBalances,
        uint256 latestBlockNumberUsed,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        internal
        override
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {}
}
