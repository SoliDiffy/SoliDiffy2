// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Mooniswap.sol";

/// @title Helper contract to deploy mooniswap pools
contract MooniswapDeployer {
    function deploy(
        IERC20 token1,
        IERC20 token2,
        string calldata name,
        string calldata symbol,
        address poolOwner
    ) public returns(Mooniswap pool) {
        pool = new Mooniswap(
            token1,
            token2,
            name,
            symbol,
            IMooniswapFactoryGovernance(msg.sender)
        );

        pool.transferOwnership(poolOwner);
    }
}
