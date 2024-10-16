pragma solidity 0.5.8;

import "../../modules/UpgradableModuleFactory.sol";
import "./DummySTOProxy.sol";

/**
 * @title Factory for deploying DummySTO module
 */
contract DummySTOFactory is UpgradableModuleFactory {

    /**
     * @notice Constructor
     * @param _setupCost Setup cost of the module
     * @param _usageCost Usage cost of the module
     * @param _logicContract Contract address that contains the logic related to `description`
     * @param _polymathRegistry Address of the Polymath registry
     * @param _isCostInPoly true = cost in Poly, false = USD
     */
    constructor (
        uint256 _setupCost,
        uint256 _usageCost,
        address _logicContract,
        address _polymathRegistry,
        bool _isCostInPoly
    )
        public
        UpgradableModuleFactory("3.0.0", _setupCost, _usageCost, _logicContract, _polymathRegistry, _isCostInPoly)
    {
        name = "DummySTO";
        title = "Dummy STO";
        description = "Dummy STO";
        typesData.push(2);
        tagsData.push("Dummy");
        tagsData.push("ETH");
        tagsData.push("STO");
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(2), uint8(1), uint8(1));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(2), uint8(1), uint8(0));
    }

    /**
     * @notice Used to launch the Module with the help of factory
     * @param _data Data used for the intialization of the module factory variables
     * @return address Contract address of the Module
     */
    function deploy(bytes calldata _data) external returns(address) {
        address dummySTO = address(new DummySTOProxy(logicContracts[latestUpgrade].version, msg.sender, polymathRegistry.getAddress("PolyToken"), logicContracts[latestUpgrade].logicContract));
        _initializeModule(dummySTO, _data);
        return dummySTO;
    }

}
