pragma solidity ^0.4.17;

import "../ManagerProxyTarget.sol";


contract ManagerProxyTargetMockV3 is ManagerProxyTarget {
    uint256 internal initValue;
    uint8 internal uint8Value;
    uint64 internal uint64Value;
    uint256 internal uint256Value;
    bytes32 internal bytes32Value;
    address internal addressValue;
    mapping (uint256 => uint256) public kvMap;

    function ManagerProxyTargetMockV3(address _controller) public Manager(_controller) {}

    function setUint8(uint8 _value) external {
        uint8Value = _value;
    }

    function setUint64(uint64 _value) external {
        uint64Value = _value;
    }

    function setUint256(uint256 _value) external {
        uint256Value = _value;
    }

    function setBytes32(bytes32 _value) external {
        bytes32Value = _value;
    }

    function setAddress(address _value) external {
        addressValue = _value;
    }

    function setKv(uint256 _key, uint256 _value) external {
        kvMap[_key] = _value;
    }
}
