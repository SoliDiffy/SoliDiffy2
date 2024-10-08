pragma solidity ^0.5.0;

import "../token/ERC20/IERC20.sol";
import "../crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

contract RefundablePostDeliveryCrowdsaleImpl is RefundablePostDeliveryCrowdsale {
    constructor (
        uint256 openingTime,
        uint256 closingTime,
        uint256 rate,
        address payable wallet,
        IERC20 token,
        uint256 goal
    )
        public
        Crowdsale(rate, wallet, token)
        RefundableCrowdsale(goal)
        TimedCrowdsale(openingTime, closingTime)
    {
        // solhint-disable-previous-line no-empty-blocks
    }
}
