pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../DelegateBase.sol";
import "../interfaces/IexecMaintenance.sol";


contract IexecMaintenanceDelegate is IexecMaintenance, DelegateBase
{
	using SafeMathExtended  for uint256;
	using IexecLibOrders_v5 for IexecLibOrders_v5.EIP712Domain;

	

	

	

	

	

	

	function _chainId()
	internal pure returns (uint256 id)
	{
		assembly { id := chainid() }
	}

	function _domain()
	internal view returns (IexecLibOrders_v5.EIP712Domain memory)
	{
		return IexecLibOrders_v5.EIP712Domain({
			name:              "iExecODB"
		, version:           "3.0-alpha"
		, chainId:           _chainId()
		, verifyingContract: address(this)
		});
	}
}
