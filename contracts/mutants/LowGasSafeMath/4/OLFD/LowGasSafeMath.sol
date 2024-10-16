// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library LowGasSafeMath {
	/// @notice Returns x + y, reverts if sum overflows uint256
	/// @param x The augend
	/// @param y The addend
	/// @return z The sum of x and y
	

	/// @notice Returns x - y, reverts if underflows
	/// @param x The minuend
	/// @param y The subtrahend
	/// @return z The difference of x and y
	

	/// @notice Returns x * y, reverts if overflows
	/// @param x The multiplicand
	/// @param y The multiplier
	/// @return z The product of x and y
	function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
		require(x == 0 || (z = x * y) / x == y);
	}

	/// @notice Returns x + y, reverts if overflows or underflows
	/// @param x The augend
	/// @param y The addend
	/// @return z The sum of x and y
	

	/// @notice Returns x - y, reverts if overflows or underflows
	/// @param x The minuend
	/// @param y The subtrahend
	/// @return z The difference of x and y
	
}
