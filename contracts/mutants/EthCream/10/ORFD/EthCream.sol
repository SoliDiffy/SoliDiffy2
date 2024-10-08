// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../Interfaces/Compound/InterestRateModel.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../Interfaces/Compound/CEtherI.sol";
import "../Interfaces/UniswapInterfaces/IWETH.sol";

import "./GenericLenderBase.sol";

/********************
 *   A lender plugin for LenderYieldOptimiser for any erc20 asset on Cream (not eth)
 *   Made by SamPriestley.com
 *   https://github.com/Grandthrax/yearnv2/blob/master/contracts/GenericLender/GenericCream.sol
 *
 ********************* */

contract EthCream is GenericLenderBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 private constant blocksPerYear = 2_300_000;
    IWETH public constant weth = IWETH(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    CEtherI public constant crETH = CEtherI(address(0xD06527D5e56A3495252A528C4987003b712860eE));

    constructor(address _strategy, string memory name) public GenericLenderBase(_strategy, name) {
        require(address(want) == address(weth), "NOT WETH");
        dust = 10;
    }

    //to receive eth from weth
    receive() external payable {}

    

    function _nav() internal view returns (uint256) {
        return want.balanceOf(address(this)).add(underlyingBalanceStored());
    }

    function underlyingBalanceStored() public view returns (uint256 balance) {
        uint256 currentCr = crETH.balanceOf(address(this));
        if (currentCr == 0) {
            balance = 0;
        } else {
            balance = currentCr.mul(crETH.exchangeRateStored()).div(1e18);
        }
    }

    

    function _apr() internal view returns (uint256) {
        return crETH.supplyRatePerBlock().mul(blocksPerYear);
    }

    

    

    //emergency withdraw. sends balance plus amount to governance
    

    //withdraw an amount including any want balance
    function _withdraw(uint256 amount) internal returns (uint256) {
        uint256 balanceUnderlying = crETH.balanceOfUnderlying(address(this));
        uint256 looseBalance = want.balanceOf(address(this));
        uint256 total = balanceUnderlying.add(looseBalance);

        if (amount > total) {
            //cant withdraw more than we own
            amount = total;
        }
        if (looseBalance >= amount) {
            want.safeTransfer(address(strategy), amount);
            return amount;
        }

        //not state changing but OK because of previous call
        uint256 liquidity = crETH.getCash();

        if (liquidity > 1) {
            uint256 toWithdraw = amount.sub(looseBalance);

            if (toWithdraw <= liquidity) {
                //we can take all
                crETH.redeemUnderlying(toWithdraw);
            } else {
                //take all we can
                crETH.redeemUnderlying(liquidity);
            }
        }

        weth.deposit{value: address(this).balance}();
        looseBalance = want.balanceOf(address(this));
        want.safeTransfer(address(strategy), looseBalance);
        return looseBalance;
    }

    

    

    //think about this
    

    

    

    function protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](2);
        protected[0] = address(want);
        protected[1] = address(crETH);
        return protected;
    }
}
