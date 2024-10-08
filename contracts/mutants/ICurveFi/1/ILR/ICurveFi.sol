// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ICurveFi {
    function get_virtual_price() external view returns (uint);
    function balances(uint) external view returns (uint);
    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external;
    function remove_liquidity(
        uint256 _amount,
        uint256[3] calldata min_amounts
    ) external;
    function remove_liquidity_one_coin(
        uint256 _token_amount, 
        int128 i, 
        uint256 min_amount
    ) external;
    function remove_liquidity_imbalance(
        uint256[3] calldata amounts,
        uint256 max_burn_amount
    ) external;
    function exchange(
        int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
    ) external;
}