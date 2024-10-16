// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.10;

import "../interfaces/IFlashMinter.sol";
import "../interfaces/IYDai.sol";


contract FlashMinterMock is IFlashMinter {

    event Parameters(address user, uint256 amount, bytes data);

    uint256 public flashBalance;

    

    function flashMint(address yDai, uint256 amount, bytes calldata data) public {
        IYDai(yDai).flashMint(address(this), amount, data);
    }
}