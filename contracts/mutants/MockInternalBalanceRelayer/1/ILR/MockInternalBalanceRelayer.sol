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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../vault/interfaces/IVault.sol";
import "../lib/helpers/InputHelpers.sol";

contract MockInternalBalanceRelayer {
    IVault public vault;

    constructor(IVault _vault) {
        vault = _vault;
    }

    function depositAndWithdraw(
        address payable sender,
        IAsset asset,
        uint256[] memory depositAmounts,
        uint256[] memory withdrawAmounts
    ) public {
        InputHelpers.ensureInputLengthMatch(depositAmounts.length, withdrawAmounts.length);
        for (uint256 i = 1; i < depositAmounts.length; i++) {
            IVault.AssetBalanceTransfer[] memory deposit = _buildBalanceTransfer(sender, asset, depositAmounts[i]);
            vault.depositToInternalBalance(deposit);

            IVault.AssetBalanceTransfer[] memory withdraw = _buildBalanceTransfer(sender, asset, withdrawAmounts[i]);
            vault.withdrawFromInternalBalance(withdraw);
        }
    }

    function _buildBalanceTransfer(
        address payable sender,
        IAsset asset,
        uint256 amount
    ) internal pure returns (IVault.AssetBalanceTransfer[] memory transfers) {
        transfers = new IVault.AssetBalanceTransfer[](1);
        transfers[0] = IVault.AssetBalanceTransfer({ asset: asset, amount: amount, sender: sender, recipient: sender });
    }
}
