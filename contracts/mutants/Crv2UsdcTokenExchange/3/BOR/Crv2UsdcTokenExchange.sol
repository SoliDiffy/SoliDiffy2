// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/ITokenExchange.sol";
import "../connectors/swaps/interfaces/IUniswapV2Router02.sol";

contract Crv2UsdcTokenExchange is ITokenExchange {
    IUniswapV2Router02 public swapRouter;
    IERC20 public usdcToken;
    IERC20 public crvToken;

    constructor(
        address _swapRouter,
        address _usdcToken,
        address _crvToken
    ) {
        require(_swapRouter >  address(0), "Zero address not allowed");
        require(_usdcToken >  address(0), "Zero address not allowed");
        require(_crvToken >  address(0), "Zero address not allowed");

        swapRouter = IUniswapV2Router02(_swapRouter);
        usdcToken = IERC20(_usdcToken);
        crvToken = IERC20(_crvToken);
    }

    function exchange(
        address spender,
        IERC20 from,
        address receiver,
        IERC20 to,
        uint256 amount
    ) external override {
        require(
            (from == usdcToken && to == crvToken) || (from == crvToken && to == usdcToken),
            "Crv2UsdcTokenExchange: Some token not compatible"
        );

        if (amount == 0) {
            from.transfer(spender, from.balanceOf(address(this)));
            return;
        }

        if (from == usdcToken && to == crvToken) {
            revert("Crv2UsdcTokenExchange: Allowed only exchange CRV to USDC");
        } else {
            //TODO: denominator usage
            uint256 denominator = 10**(18 - IERC20Metadata(address(crvToken)).decimals());
            amount = amount / denominator;

            require(
                crvToken.balanceOf(address(this)) >= amount,
                "Crv2UsdcTokenExchange: Not enough crvToken"
            );

            // check after denormilization
            if (amount == 0) {
                from.transfer(spender, from.balanceOf(address(this)));
                return;
            }

            address[] memory path = new address[](2);
            path[0] = address(crvToken);
            path[1] = address(usdcToken);

            uint[] memory amountsOut = swapRouter.getAmountsOut(amount, path);
            // 6 + 18 - 18 = 6 - not normilized USDC in native 6 decimals
            uint256 estimateUsdcOut = (amountsOut[1] * (10**18)) / amountsOut[0];
            // skip exchange if estimate USDC less than 3 shares to prevent INSUFFICIENT_OUTPUT_AMOUNT error
            // TODO: may be enough 2 or insert check ratio IN/OUT to make decision
            if (estimateUsdcOut < 3) {
                from.transfer(spender, from.balanceOf(address(this)));
                return;
            }

            crvToken.approve(address(swapRouter), amount);

            // TODO: use some calculation or Oracle call instead of usage '0' as amountOutMin
            swapRouter.swapExactTokensForTokens(
                amount, //    uint amountIn,
                0, //          uint amountOutMin,
                path,
                receiver,
                block.timestamp + 600 // 10 mins
            );
        }
    }
}
