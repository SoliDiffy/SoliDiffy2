// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '../helpers/UniswapNFTHelper.sol';
import '../helpers/SwapHelper.sol';
import '../helpers/ERC20Helper.sol';
import '../utils/Storage.sol';
import '../../interfaces/IPositionManager.sol';
import '../../interfaces/actions/IZapIn.sol';

contract ZapIn is IZapIn {
    ///@notice emitted when a UniswapNFT is zapped in
    ///@param positionManager address of PositionManager
    ///@param tokenId Id of zapped token
    ///@param tokenIn address of token zapped in
    ///@param amountIn amount of tokenIn zapped in
    event ZappedIn(address indexed positionManager, uint256 tokenId, address tokenIn, uint256 amountIn);

    ///@notice mints a uni NFT with a single input token, the token in input can be different from the two position tokens
    ///@param tokenIn address of input token
    ///@param amountIn amount of input token
    ///@param token0 address token0 of the pool
    ///@param token1 address token1 of the pool
    ///@param tickLower lower bound of desired position
    ///@param tickUpper upper bound of desired position
    ///@param fee fee tier of the pool
    ///@return tokenId of minted NFT
    

    ///@notice mints a UniswapV3 position NFT
    ///@param token0Address address of the first token
    ///@param token1Address address of the second token
    ///@param fee pool fee level
    ///@param tickLower lower tick of the position
    ///@param tickUpper upper tick of the position
    ///@param amount0Desired amount of first token in position
    ///@param amount1Desired amount of second token in position
    function _mint(
        address token0Address,
        address token1Address,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Desired,
        uint256 amount1Desired
    )
        internal
        returns (
            uint256 tokenId,
            uint256 amount0Deposited,
            uint256 amount1Deposited
        )
    {
        StorageStruct storage Storage = PositionManagerStorage.getStorage();

        ERC20Helper._approveToken(
            token0Address,
            Storage.uniswapAddressHolder.nonfungiblePositionManagerAddress(),
            amount0Desired
        );
        ERC20Helper._approveToken(
            token1Address,
            Storage.uniswapAddressHolder.nonfungiblePositionManagerAddress(),
            amount1Desired
        );

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0Address,
            token1: token1Address,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 120
        });

        (tokenId, , amount0Deposited, amount1Deposited) = INonfungiblePositionManager(
            Storage.uniswapAddressHolder.nonfungiblePositionManagerAddress()
        ).mint(params);

        IPositionManager(address(this)).middlewareDeposit(tokenId);
    }

    ///@notice orders token addresses
    ///@param token0 address of token0
    ///@param token1 address of token1
    ///@return address first token address
    ///@return address second token address
    function _reorderTokens(address token0, address token1) internal pure returns (address, address) {
        if (token0 > token1) {
            return (token1, token0);
        } else {
            return (token0, token1);
        }
    }
}
