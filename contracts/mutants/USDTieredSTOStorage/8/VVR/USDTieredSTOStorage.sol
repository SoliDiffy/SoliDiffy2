pragma solidity 0.5.8;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title Contract used to store layout for the USDTieredSTO storage
 */
contract USDTieredSTOStorage {

    bytes32 public constant INVESTORSKEY = 0xdf3a8dd24acdd05addfc6aeffef7574d2de3f844535ec91e8e0f3e45dba96731; //keccak256(abi.encodePacked("INVESTORS"))
    
    /////////////
    // Storage //
    /////////////
    struct Tier {
        // NB rates mentioned below are actually price and are used like price in the logic.
        // How many token units a buyer gets per USD in this tier (multiplied by 10**18)
        uint256 rate;
        // How many token units a buyer gets per USD in this tier (multiplied by 10**18) when investing in POLY up to tokensDiscountPoly
        uint256 rateDiscountPoly;
        // How many tokens are available in this tier (relative to totalSupply)
        uint256 tokenTotal;
        // How many token units are available in this tier (relative to totalSupply) at the ratePerTierDiscountPoly rate
        uint256 tokensDiscountPoly;
        // How many tokens have been sold in this tier (relative to totalSupply)
        uint256 totalTokensSoldInTier;
        // How many tokens have been sold in this tier (relative to totalSupply) for each fund raise type
        mapping(uint8 => uint256) tokenSoldPerFundType;
        // How many tokens have been sold in this tier (relative to totalSupply) at discounted POLY rate
        uint256 soldDiscountPoly;
    }

    mapping(address => uint256) public nonAccreditedLimitUSDOverride;

    mapping(bytes32 => mapping(bytes32 => string)) oracleKeys;

    // Determine whether users can invest on behalf of a beneficiary
    bool internal allowBeneficialInvestments;

    // List of stable coin addresses
    IERC20[] public stableTokens;

    // Current tier
    uint256 internal currentTier;

    // Amount of USD funds raised
    uint256 internal fundsRaisedUSD;

    // Amount of stable coins raised
    mapping (address => uint256) public stableCoinsRaised;

    // Amount in USD invested by each address
    mapping(address => uint256) public investorInvestedUSD;

    // Amount in fund raise type invested by each investor
    mapping(address => mapping(uint8 => uint256)) public investorInvested;

    // List of active stable coin addresses
    mapping (address => bool) internal stableTokenEnabled;

    // Default limit in USD for non-accredited investors multiplied by 10**18
    uint256 internal nonAccreditedLimitUSD;

    // Minimum investable amount in USD
    uint256 internal minimumInvestmentUSD;

    // Final amount of tokens returned to issuer
    uint256 internal finalAmountReturned;

    // Array of Tiers
    Tier[] public tiers;

    // Optional custom Oracles.
    mapping(bytes32 => mapping(bytes32 => address)) customOracles;

    bytes32 public denominatedCurrency;
}
