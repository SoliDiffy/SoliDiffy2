pragma solidity 0.5.8;

import "./PLCRVotingCheckpointProxy.sol";
import "../../../UpgradableModuleFactory.sol";

/**
 * @title Factory for deploying PLCRVotingCheckpoint module
 */
contract PLCRVotingCheckpointFactory is UpgradableModuleFactory {

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
        UpgradableModuleFactory("", _setupCost, _usageCost, _logicContract, _polymathRegistry, _isCostInPoly)
    {
        initialVersion = "";
        name = "";
        title = "";
        description = "";
        typesData.push(4);
        typesData.push(9); // Auto whitelist treasury wallet
        tagsData.push("");
        tagsData.push("");
        tagsData.push("");
        compatibleSTVersionRange[""] = VersionUtils.pack(uint8(3), uint8(0), uint8(0));
        compatibleSTVersionRange[""] = VersionUtils.pack(uint8(3), uint8(1), uint8(0));

    }

    /**
     * @notice used to launch the Module with the help of factory
     * @return address Contract address of the Module
     */
    function deploy(bytes calldata _data) external returns(address) {
        address plcrVotingCheckpoint = address(new PLCRVotingCheckpointProxy(logicContracts[latestUpgrade].version, msg.sender, polymathRegistry.getAddress("PolyToken"), logicContracts[latestUpgrade].logicContract));
        _initializeModule(plcrVotingCheckpoint, _data);
        return plcrVotingCheckpoint;
    }
}
