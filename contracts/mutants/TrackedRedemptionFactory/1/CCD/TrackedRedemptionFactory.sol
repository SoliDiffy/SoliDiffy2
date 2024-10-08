pragma solidity 0.5.8;

import "./TrackedRedemption.sol";
import "../../ModuleFactory.sol";

/**
 * @title Factory for deploying GeneralTransferManager module
 */
contract TrackedRedemptionFactory is ModuleFactory {
    /**
     * @notice Constructor
     * @param _setupCost Setup cost of module
     * @param _usageCost Usage cost of the module
     * @param _polymathRegistry Address of the Polymath registry
     * @param _isCostInPoly true = cost in Poly, false = USD
     */
    

    /**
     * @notice Used to launch the Module with the help of factory
     * @return Address Contract address of the Module
     */
    function deploy(
        bytes calldata _data
    )
        external
        returns(address)
    {
        address trackedRedemption = address(new TrackedRedemption(msg.sender, polymathRegistry.getAddress("PolyToken")));
        _initializeModule(trackedRedemption, _data);
        return trackedRedemption;
    }

}
