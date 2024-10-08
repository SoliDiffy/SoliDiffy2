// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "../converter/types/liquidity-pool-v1/LiquidityPoolV1Converter.sol";

contract TestLiquidityPoolV1Converter is LiquidityPoolV1Converter {
    uint256 public currentTime;

    

    function setEtherToken(IEtherToken _etherToken) public {
        etherToken = _etherToken;
    }

    function time() internal view override returns (uint256) {
        return currentTime != 0 ? currentTime : now;
    }

    function setTime(uint256 _currentTime) public {
        currentTime = _currentTime;
    }
}
