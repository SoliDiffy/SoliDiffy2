// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

import './FeeMath.sol';
import './FullMath.sol';
import './LowGasSafeMath.sol';
import './UnsafeMath.sol';

import './SafeCast.sol';
import './FixedPoint96.sol';

library SqrtPriceMath {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    // calculate liquidity * sqrt(P) / (liquidity +- x * sqrt(P))
    // or, if this is impossible because of overflow,
    // liquidity / (liquidity / sqrt(P) +- x)
    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        uint256 product = amount * sqrtPX96;
        if (product / amount == sqrtPX96) {
            if (add) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    // always fits in 160 bits
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            } else {
                uint256 denominator = numerator1 - product;
                if (denominator <= numerator1 && denominator != 0)
                    return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
            }
        }

        uint256 denominator1 = add ? (numerator1 / sqrtPX96).add(amount) : (numerator1 / sqrtPX96).sub(amount);
        require(denominator1 != 0);

        return UnsafeMath.divRoundingUp(numerator1, denominator1).toUint160();
    }

    // calculate sqrt(P) +- y / liquidity
    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // if we're adding (subtracting), rounding down requires rounding the quotient down (up)
        // in both cases, avoid a mulDiv for most inputs
        uint256 quotient =
            add
                ? (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                )
                : (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

        return (add ? uint256(sqrtPX96).add(quotient) : uint256(sqrtPX96).sub(quotient)).toUint160();
    }

    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we don't pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    // calculate liquidity / sqrt(Q) - liquidity / sqrt(P), i.e.
    // liquidity * (sqrt(P) - sqrt(Q)) / (sqrt(P) * sqrt(Q))
    function getAmount0Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        // TODO: this require should never be hit
        require(sqrtPX96 >= sqrtQX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtPX96 - sqrtQX96;

        return
            roundUp
                ? UnsafeMath.divRoundingUp(FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtPX96), sqrtQX96)
                : FullMath.mulDiv(numerator1, numerator2, sqrtPX96) / sqrtQX96;
    }

    // calculate liquidity * (sqrt(Q) - sqrt(P))
    function getAmount1Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        // TODO: this require should never be hit
        require(sqrtQX96 >= sqrtPX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtQX96 - sqrtPX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtQX96 - sqrtPX96, FixedPoint96.Q96);
    }

    // helpers to get signed deltas for use in setPosition
    function getAmount0Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount0Delta(sqrtPX96, sqrtQX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtPX96, sqrtQX96, uint128(liquidity), true).toInt256();
    }

    function getAmount1Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount1Delta(sqrtPX96, sqrtQX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtPX96, sqrtQX96, uint128(liquidity), true).toInt256();
    }
}