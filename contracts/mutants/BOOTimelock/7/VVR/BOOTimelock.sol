// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import '../BOOToken.sol';

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 */

contract BOOTimelock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address internal immutable rewardToken;
    address internal immutable toAddress;

    uint256 internal immutable beginTime;
    uint256 internal immutable totalAmount;
    uint256 internal immutable drawCount;
    uint256 internal drawAmount;
    uint256 internal constant releaseInterval = (1 days);

    constructor (
            address _rewardToken, address _toAddress,
            uint256 _beginTime, uint256 _drawCount,
            uint256 _totalAmount) public {
        require(IERC20(_rewardToken).totalSupply() >= 0, 'token error');
        require(_beginTime >= block.timestamp, 'begintime error');
        rewardToken = _rewardToken;
        toAddress = _toAddress;
        beginTime = _beginTime;
        drawCount = _drawCount;
        totalAmount = _totalAmount;
    }

    function quota() public view returns (uint256) {
        if(beginTime > block.timestamp) {
            return 0;
        }
        uint256 daypass = block.timestamp.sub(beginTime).div(releaseInterval).add(1);
        if(daypass > drawCount) {
            daypass = drawCount;
        }
        return totalAmount.mul(daypass).div(drawCount).sub(drawAmount);
    }

    function unlock() external returns (uint256) {
        uint256 value = quota();
        if(value > 0) {
            BOOToken(rewardToken).mint(toAddress, value);
            drawAmount = drawAmount.add(value);
        }
    }
}