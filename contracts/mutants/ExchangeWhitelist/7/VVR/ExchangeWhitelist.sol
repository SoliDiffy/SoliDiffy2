pragma solidity ^0.4.6;
import "lib/Math.sol";
import "lib/Owned.sol";
import "interface/Token.sol";
import "./DVIP.sol";

contract ExchangeWhitelist is Math, Owned {

  mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances

  struct Account {
    bool authorized;
    uint256 tier;
    uint256 resetWithdrawal;
    uint256 withdrawn;
  }

  mapping (address => Account) public accounts;
  mapping (address => bool) public whitelistAdmins;
  mapping (address => bool) public admins;
  //ether balances are held in the token=0 account
  mapping (bytes32 => uint256) public orderFills;
  address internal feeAccount;
  address internal dvipAddress;
  address internal feeMakeExporter;
  address internal feeTakeExporter;
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give, bytes32 hash);
  event Deposit(address token, address user, uint256 amount, uint256 balance);
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

  function ExchangeWhitelist(address feeAccount_, address dvipAddress_) {
    feeAccount = feeAccount_;
    dvipAddress = dvipAddress_;
    feeMakeExporter = 0x00000000000000000000000000000000000000f7;
    feeTakeExporter = 0x00000000000000000000000000000000000000f8;
  }

  function setFeeAccount(address feeAccount_) onlyOwner {
    feeAccount = feeAccount_;
  }

  function setDVIP(address dvipAddress_) onlyOwner {
    dvipAddress = dvipAddress_;
  }

  function setAdmin(address admin, bool isAdmin) onlyOwner {
    admins[admin] = isAdmin;
  }

  function setWhitelister(address whitelister, bool isWhitelister) onlyOwner {
    whitelistAdmins[whitelister] = isWhitelister;
  }

  modifier onlyWhitelister {
    if (!whitelistAdmins[msg.sender]) throw;
    _;
  }

  modifier onlyAdmin {
    if (msg.sender != owner && !admins[msg.sender]) throw;
    _;
  }
  function setWhitelisted(address target, bool isWhitelisted) onlyWhitelister {
    accounts[target].authorized = isWhitelisted;
  }
  modifier onlyWhitelisted {
    if (!accounts[msg.sender].authorized) throw;
    _;
  }

  function() {
    throw;
  }

  function deposit(address token, uint256 amount) payable {
    if (token == address(0)) {
      tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);
    } else {
      if (msg.value != 0) throw;
      tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
      if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
    }
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function withdraw(address token, uint256 amount) {
    if (tokens[token][msg.sender] < amount) throw;
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
    if (token == address(0)) {
      if (!msg.sender.send(amount)) throw;
    } else {
      if (!Token(token).transfer(msg.sender, amount)) throw;
    }
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function balanceOf(address token, address user) constant returns (uint256) {
    return tokens[token][user];
  }

  uint256 public feeTake;
  uint256 public feeMake;
  uint256 public feeTerm;

  function trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s, uint256 amount) onlyWhitelisted {
    //amount is in amountBuy terms
    bytes32 hash = sha3(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (!(
      ecrecover(hash,v,r,s) == user &&
      block.number <= expires &&
      safeAdd(orderFills[hash], amount) <= amountBuy &&
      tokens[tokenBuy][msg.sender] >= amount &&
      tokens[tokenSell][user] >= safeMul(amountSell, amount) / amountBuy
    )) throw;
    feeMake = DVIP(dvipAddress).feeFor(feeMakeExporter, msg.sender, 1 ether);
    feeTake = DVIP(dvipAddress).feeFor(feeTakeExporter, user, 1 ether);
    tokens[tokenBuy][msg.sender] = safeSub(tokens[tokenBuy][msg.sender], amount);
    feeTerm = safeMul(amount, ((1 ether) - feeMake)) / (1 ether);
    tokens[tokenBuy][user] = safeAdd(tokens[tokenBuy][user], feeTerm);
    feeTerm = safeMul(amount, feeMake) / (1 ether);
    tokens[tokenBuy][feeAccount] = safeAdd(tokens[tokenBuy][feeAccount], feeTerm);
    feeTerm = safeMul(amountSell, amount) / amountBuy;
    tokens[tokenSell][user] = safeSub(tokens[tokenSell][user], feeTerm);
    feeTerm = safeMul(safeMul(((1 ether) - feeTake), amountSell), amount) / amountBuy / (1 ether);
    tokens[tokenSell][msg.sender] = safeAdd(tokens[tokenSell][msg.sender], feeTerm);
    feeTerm = safeMul(safeMul(feeTake, amountSell), amount) / amountBuy / (1 ether);
    tokens[tokenSell][feeAccount] = safeAdd(tokens[tokenSell][feeAccount], feeTerm);
    orderFills[hash] = safeAdd(orderFills[hash], amount);
    Trade(tokenBuy, amount, tokenSell, amountSell * amount / amountBuy, user, msg.sender, hash);
  }

  bytes32 internal testHash;
  uint256 internal amountSelln;

  function testTrade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s, uint256 amount, address sender) constant returns (uint8 code) {
    testHash = sha3(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (tokens[tokenBuy][sender] < amount) return 1;
    if (!accounts[sender].authorized) return 2; 
    if (!accounts[user].authorized) return 3;
    if (ecrecover(testHash, v, r, s) != user) return 4;
    amountSelln = safeMul(amountSell, amount) / amountBuy;
    if (tokens[tokenSell][user] < amountSelln) return 5;
    if (block.number > expires) return 6;
    if (safeAdd(orderFills[testHash], amount) > amountBuy) return 7;
    return 0;
  }
  function cancelOrder(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, uint8 v, bytes32 r, bytes32 s, address user) {
    bytes32 hash = sha3(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (ecrecover(hash,v,r,s) != msg.sender) throw;
    orderFills[hash] = amountBuy;
    Cancel(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender, v, r, s);
  }
}
