pragma solidity ^0.4.17;

import "../ManagerProxyTarget.sol";


contract ManagerProxyTargetMockV1 is ManagerProxyTarget {
    uint256 internal initValue;
    uint8 internal uint8Value;
    uint64 internal uint64Value;
    uint256 internal uint256Value;
    bytes32 internal bytes32Value;
    address internal addressValue;
    string internal stringValue;
    bytes internal bytesValue;
    uint256 internal tupleValue1;
    uint256 public tupleValue2;
    bytes32 public tupleValue3;

    function ManagerProxyTargetMockV1(address _controller) public Manager(_controller) {}

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

    function setString(string _value) external {
        stringValue = _value;
    }

    function setBytes(bytes _value) external {
        bytesValue = _value;
    }

    function setTuple(uint256 _value1, uint256 _value2, bytes32 _value3) external {
        tupleValue1 = _value1;
        tupleValue2 = _value2;
        tupleValue3 = _value3;
    }

    function getTuple() external view returns (uint256, uint256, bytes32) {
        return (tupleValue1, tupleValue2, tupleValue3);
    }
}
