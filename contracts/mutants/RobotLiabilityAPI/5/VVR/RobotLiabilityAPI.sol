pragma solidity ^0.4.24;

import './LiabilityFactory.sol';
import './XRT.sol';

contract RobotLiabilityAPI {
    bytes   internal model;
    bytes   internal objective;
    bytes   internal result;

    ERC20   internal token;
    uint256 internal cost;
    uint256 public lighthouseFee;
    uint256 public validatorFee;

    bytes32 public askHash;
    bytes32 public bidHash;

    address public promisor;
    address public promisee;
    address public validator;

    bool    public isConfirmed;
    bool    public isFinalized;

    LiabilityFactory public factory;
}
