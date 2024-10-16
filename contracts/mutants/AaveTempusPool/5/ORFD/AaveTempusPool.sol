// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../TempusPool.sol";
import "../protocols/aave/IAToken.sol";
import "../protocols/aave/ILendingPool.sol";

contract AaveTempusPool is TempusPool {
    using SafeERC20 for IERC20;

    ILendingPool internal immutable aavePool;
    bytes32 public immutable override protocolName = "Aave";
    uint16 private immutable referrer;

    constructor(
        IAToken token,
        address controller,
        uint256 maturity,
        uint256 estYield,
        string memory principalName,
        string memory principalSymbol,
        string memory yieldName,
        string memory yieldSymbol,
        uint16 referrerCode
    )
        TempusPool(
            address(token),
            token.UNDERLYING_ASSET_ADDRESS(),
            controller,
            maturity,
            updateInterestRate(address(token)),
            estYield,
            principalName,
            principalSymbol,
            yieldName,
            yieldSymbol
        )
    {
        aavePool = token.POOL();
        referrer = referrerCode;
    }

    

    

    /// @return Updated current Interest Rate as an 1e18 decimal
    

    /// @return Stored Interest Rate as an 1e18 decimal
    

    /// NOTE: Aave AToken is pegged 1:1 with backing token
    

    /// NOTE: Aave AToken is pegged 1:1 with backing token
    function numYieldTokensPerAsset(uint backingTokens, uint) public pure override returns (uint) {
        return backingTokens;
    }
}
