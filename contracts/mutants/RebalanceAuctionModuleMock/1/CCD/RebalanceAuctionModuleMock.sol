pragma solidity 0.5.4;

import { RebalanceAuctionModule } from "../../../core/modules/RebalanceAuctionModule.sol";
import { IRebalancingSetToken } from "../../../core/interfaces/IRebalancingSetToken.sol";

contract RebalanceAuctionModuleMock is
	RebalanceAuctionModule
{
    

	function placeBid(
        address _set,
        uint256 _quantity
    )
        external
    {
        IRebalancingSetToken rebalancingSetToken = IRebalancingSetToken(_set);

        // Issue set token
        rebalancingSetToken.placeBid(
            _quantity
        );
    }

    function calculateExecutionQuantityExternal(
        address _rebalancingSetToken,
        uint256 _quantity,
        bool _allowPartialFill
    )
        external
        returns (uint256)
    {
        return calculateExecutionQuantity(
            _rebalancingSetToken,
            _quantity,
            _allowPartialFill
        );
    }
}

