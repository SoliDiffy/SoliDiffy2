// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
      ___       ___       ___       ___       ___
     /\  \     /\__\     /\  \     /\  \     /\  \
    /::\  \   /:/ _/_   /::\  \   _\:\  \    \:\  \
    \:\:\__\ /:/_/\__\ /::\:\__\ /\/::\__\   /::\__\
     \::/  / \:\/:/  / \:\::/  / \::/\/__/  /:/\/__/
     /:/  /   \::/  /   \::/  /   \:\__\    \/__/
     \/__/     \/__/     \/__/     \/__/

*
* MIT License
* ===========
*
* Copyright (c) 2021 QubitFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IPancakeFactory.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPresaleLocker.sol";
import "../interfaces/IQubitPresale.sol";
import "../interfaces/IPriceCalculator.sol";
import "../library/SafeToken.sol";

contract QubitPresale is IQubitPresale, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMath for uint;
    using SafeToken for address;

    /* ========== CONSTANTS ============= */

    address public constant BUNNY = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant QBT = 0x17B7163cf1Dbd286E262ddc68b553D899B93f526;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public constant BUNNY_WBNB_LP = 0x5aFEf8567414F29f0f927A0F2787b188624c10E2;
    address public constant QBT_WBNB_LP = 0x67EFeF66A55c4562144B9AcfCFbc62F9E4269b3e;

    address public constant DEPLOYER = 0xbeE397129374D0b4db7bf1654936951e5bdfe5a6;

    IPancakeRouter02 private constant router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakeFactory private constant factory = IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    IPriceCalculator public constant priceCalculator = IPriceCalculator(0x20E5E35ba29dC3B540a1aee781D0814D5c77Bce6);

    /* ========== STATE VARIABLES ========== */

    uint public startTime;
    uint public endTime;
    uint public presaleAmountUSD;
    uint public totalBunnyBnbLp;
    uint public qbtAmount;
    uint public override qbtBnbLpAmount;
    uint public override lpPriceAtArchive;
    uint private _distributionCursor;

    mapping(address => uint) public bunnyBnbLpOf;
    mapping(address => bool) public claimedOf;
    address[] public accountList;
    bool public archived;

    IPresaleLocker public qbtBnbLocker;

    mapping(address => uint) public refundLpOf;

    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint amount);
    event Distributed(uint length, uint remain);

    /* ========== INITIALIZER ========== */

    function initialize(
        uint _startTime,
        uint _endTime,
        uint _presaleAmountUSD,
        uint _qbtAmount
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        startTime = _startTime;
        endTime = _endTime;
        presaleAmountUSD = _presaleAmountUSD;
        qbtAmount = _qbtAmount;

        BUNNY_WBNB_LP.safeApprove(address(router), uint(~0));
        QBT.safeApprove(address(router), uint(~0));
        BUNNY.safeApprove(address(router), uint(~0));
        WBNB.safeApprove(address(router), uint(~0));
    }

    /* ========== VIEWS ========== */

    

    

    

    function presaleDataOf(address account) public view returns (PresaleData memory) {
        PresaleData memory presaleData;
        presaleData.startTime = startTime;
        presaleData.endTime = endTime;
        presaleData.userLpAmount = bunnyBnbLpOf[account];
        presaleData.totalLpAmount = totalBunnyBnbLp;
        presaleData.claimedOf = claimedOf[account];
        presaleData.refundLpAmount = refundLpOf[account];
        presaleData.qbtBnbLpAmount = qbtBnbLpAmount;

        return presaleData;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    

    

    

    

    /* ========== RESTRICTED FUNCTIONS ========== */

    

    

    

    function sweep(uint _lpAmount, uint _offerAmount) public override onlyOwner {
        require(_lpAmount <= IBEP20(BUNNY_WBNB_LP).balanceOf(address(this)), "QubitPresale: not enough token 0");
        require(_offerAmount <= IBEP20(QBT).balanceOf(address(this)), "QubitPresale: not enough token 1");
        BUNNY_WBNB_LP.safeTransfer(msg.sender, _lpAmount);
        QBT.safeTransfer(msg.sender, _offerAmount);
    }

    /* ========== PRIVATE FUNCTIONS ========== */
}
