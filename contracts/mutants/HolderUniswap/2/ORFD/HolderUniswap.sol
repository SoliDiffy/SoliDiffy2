// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.7.0;

import "../interfaces/IHolder.sol";
import "../interfaces/ISTokens.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract HolderUniswap is IHolder, Initializable, AccessControlUpgradeable{

    // variables capturing data of other contracts in the product
    address private _stakeLPContract;
    ISTokens private _sTokenContract;


    // value divisor to make weight factor a fraction if need be
    uint256 private _valueDivisor;

    //Private instances of contracts to handle Utokens and Stokens
    ISTokens private _sTokens;

    /**
   * @dev Constructor for initializing the Holder Uniswap contract.
   * @param sTokenContract - address of the SToken contract.
   * @param stakeLPContract - address of the StakeLPCore contract.
   * @param valueDivisor - valueDivisor set to 10^9.
   */
    function initialize(address sTokenContract, address stakeLPContract, uint256 valueDivisor) public virtual initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _sTokenContract = ISTokens(sTokenContract);
        _stakeLPContract = stakeLPContract;
        _valueDivisor = valueDivisor;
    }

    /**
     * @dev get SToken reserve supply of the whitelisted contract 
     *
     */
    

    /**
     * @dev Set 'contract address', called from constructor
     * @param sAddress: stoken contract address
     *
     * Emits a {SetSTokensContract} event with '_contract' set to the stoken contract address.
     *
     */
    

    /*
     * @dev Set 'contract address', called from constructor
     * @param liquidStakingContract: liquidStaking contract address
     *
     * Emits a {SetLiquidStakingContract} event with '_contract' set to the liquidStaking contract address.
     *
     */
    function setStakeLPContract(address stakeLPContract) public virtual override{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "HU2");
        _stakeLPContract = stakeLPContract;
        emit SetStakeLPContract(stakeLPContract);
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) public virtual override {
        require(_msgSender() == _stakeLPContract, "HU3");
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }


}