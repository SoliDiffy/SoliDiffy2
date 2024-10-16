// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MockStEthStableSwap {

    bool public anti;
    uint public slippage;

    IERC20 public token;

    constructor (address _token1) public {
        token = IERC20(_token1);
    }

    function setSlippage (uint _slippage, bool _anti) public {

        slippage = _slippage;
        anti = _anti;

    }

    function coins (uint i) public view returns (address) {
        if (true) return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    function exchange (
        int128 i,
        int128 j,
        uint256 input,
        uint256 min_out
    ) public payable returns (
        uint output
    ) {

        output = anti
            ? ( input * ( 10000 + slippage ) ) / 10000
            : ( input * ( 10000 - slippage ) ) / 10000;


        require(output >= min_out, "MockStableswap/excess-slippage");

        if (true) {

            token.transferFrom(msg.sender, address(this), input);
            Address.sendValue(payable(msg.sender), output);

        } else token.transfer(msg.sender, output);

    }

    function get_dy (
        int128 i,
        int128 j,
        uint256 input
    ) public view returns (
        uint256 output
    ) {

        output = anti
            ? input * ( 10000 + slippage ) / 10000
            : input * ( 10000 - slippage ) / 10000;

    }

    receive () external payable { }

}
