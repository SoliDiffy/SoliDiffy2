// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import '../interfaces/IBEP20.sol';
import '../token/SafeBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './MasterChef.sol';

contract LotteryRewardPool is Ownable {
    using SafeBEP20 for IBEP20;

    MasterChef public chef;
    address public adminAddress;
    address public receiver;
    IBEP20 public lptoken;
    IBEP20 public cake;

    constructor(
        MasterChef _chef,
        IBEP20 _cake,
        address _admin,
        address _receiver
    ) {
        chef = _chef;
        cake = _cake;
        adminAddress = _admin;
        receiver = _receiver;
    }

    event StartFarming(address indexed user, uint256 indexed pid);
    event Harvest(address indexed user, uint256 indexed pid);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    function startFarming(uint256 _pid, IBEP20 _lptoken, uint256 _amount) external onlyOwner {
        _lptoken.safeApprove(address(chef), _amount);
        chef.deposit(_pid, _amount);
        emit StartFarming(msg.sender, _pid);
    }

    function  harvest(uint256 _pid) external onlyOwner {
        chef.deposit(_pid, 0);
        uint256 balance = cake.balanceOf(address(this));
        cake.safeTransfer(receiver, balance);
        emit Harvest(msg.sender, _pid);
    }

    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function  pendingReward(uint256 _pid) external view returns (uint256) {
        return chef.pendingCake(_pid, address(this));
    }

    // EMERGENCY ONLY.
    function emergencyWithdraw(IBEP20, uint256 _amount) external onlyAdmin {
        cake.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function setAdmin(address _admin) external onlyOwner {
        adminAddress = _admin;
    }

}
