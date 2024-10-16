pragma solidity ^0.5.16;

import "../interfaces/IAddressResolver.sol";
import "../interfaces/ISynthetix.sol";

contract MockThirdPartyExchangeContract {
    IAddressResolver public resolver;

    constructor(IAddressResolver _resolver) internal {
        resolver = _resolver;
    }

    function exchange(
        bytes32 src,
        uint amount,
        bytes32 dest
    ) public {
        ISynthetix synthetix = ISynthetix(resolver.getAddress("Synthetix"));

        synthetix.exchangeWithTrackingForInitiator(src, amount, dest, address(this), "TRACKING_CODE");
    }
}
