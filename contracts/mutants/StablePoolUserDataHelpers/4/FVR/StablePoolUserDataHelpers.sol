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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./StablePool.sol";

library StablePoolUserDataHelpers {
    function joinKind(bytes memory self) public pure returns (StablePool.JoinKind) {
        return abi.decode(self, (StablePool.JoinKind));
    }

    function exitKind(bytes memory self) public pure returns (StablePool.ExitKind) {
        return abi.decode(self, (StablePool.ExitKind));
    }

    function initialAmountsIn(bytes memory self) public pure returns (uint256[] memory amountsIn) {
        (, amountsIn) = abi.decode(self, (StablePool.JoinKind, uint256[]));
    }

    function allTokensInForExactBptOut(bytes memory self) public pure returns (uint256 bptAmountOut) {
        (, bptAmountOut) = abi.decode(self, (StablePool.JoinKind, uint256));
    }

    function exactBptInForAllTokensOut(bytes memory self) internal pure returns (uint256 bptAmountIn) {
        (, bptAmountIn) = abi.decode(self, (StablePool.ExitKind, uint256));
    }
}
