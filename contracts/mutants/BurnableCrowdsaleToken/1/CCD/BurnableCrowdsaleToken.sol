/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.8;

import "./BurnableToken.sol";
import "./CrowdsaleToken.sol";

/**
 * A crowdsaled token that you can also burn.
 *
 */
contract BurnableCrowdsaleToken is BurnableToken, CrowdsaleToken {

  
}
