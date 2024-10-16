pragma solidity ^0.6.6;

import "../core/ACOFactory.sol";

/**
 * @title ACOFactoryForTest
 * @dev The contract is only for test purpose.
 */
contract ACOFactoryForTest is ACOFactory {
    
    event SetExtraData(uint256 lastValue, uint256 newValue);
    
    mapping(uint256 => uint256) public extraDataMap;
    uint256 public extraData;
    
    
    
    
    
    function setExtraData(uint256 newValue) onlyFactoryAdmin external virtual {
        _setExtraData(newValue);
    }
    
    function _setExtraData(uint256 newValue) internal virtual {
        emit SetExtraData(extraDataMap[extraData], newValue);
        extraData++;
        extraDataMap[extraData] = newValue;
    }
}