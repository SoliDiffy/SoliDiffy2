pragma solidity ^0.5.16;
import "./SafeMath.sol";
import "./IBEP20.sol";

contract VAIVaultAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address internal admin;

    /**
    * @notice Pending administrator for this contract
    */
    address internal pendingAdmin;

    /**
    * @notice Active brains of VAI Vault
    */
    address internal vaiVaultImplementation;

    /**
    * @notice Pending brains of VAI Vault
    */
    address internal pendingVAIVaultImplementation;
}

contract VAIVaultStorage is VAIVaultAdminStorage {
    /// @notice The XVS TOKEN!
    IBEP20 internal xvs;

    /// @notice The VAI TOKEN!
    IBEP20 internal vai;

    /// @notice Guard variable for re-entrancy checks
    bool internal _notEntered;

    /// @notice XVS balance of vault
    uint256 public xvsBalance;

    /// @notice Accumulated XVS per share
    uint256 public accXVSPerShare;

    //// pending rewards awaiting anyone to update
    uint256 public pendingRewards;

    /// @notice Info of each user.
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    // Info of each user that stakes tokens.
    mapping(address => UserInfo) public userInfo;
}
