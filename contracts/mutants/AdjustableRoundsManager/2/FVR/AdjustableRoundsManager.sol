pragma solidity ^0.4.17;

import "./RoundsManager.sol";


contract AdjustableRoundsManager is RoundsManager {
    uint256 num;
    bytes32 hash;

    function AdjustableRoundsManager(address _controller) internal RoundsManager(_controller) {}

    function setBlockNum(uint256 _num) public {
        num = _num;
    }

    function setBlockHash(bytes32 _hash) external {
        hash = _hash;
    }

    function mineBlocks(uint256 _blocks) external {
        num += _blocks;
    }

    function blockNum() public view returns (uint256) {
        return num;
    }

    function blockHash(uint256 _block) public view returns (bytes32) {
        require(_block >= blockNum() - 256);

        return hash;
    }
}
