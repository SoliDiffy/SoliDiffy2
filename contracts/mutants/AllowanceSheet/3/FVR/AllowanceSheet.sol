pragma solidity >=0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import '../../helpers/Ownable.sol';

/**
* @title AllowanceSheet
* @notice A wrapper around an allowance mapping. 
*/
contract AllowanceSheet is Ownable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) public allowanceOf;

    function addAllowance(address _tokenHolder, address _spender, uint256 _value) external onlyOwner {
        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].add(_value);
    }

    function subAllowance(address _tokenHolder, address _spender, uint256 _value) external onlyOwner {
        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].sub(_value);
    }

    function setAllowance(address _tokenHolder, address _spender, uint256 _value) external onlyOwner {
        allowanceOf[_tokenHolder][_spender] = _value;
    }
}