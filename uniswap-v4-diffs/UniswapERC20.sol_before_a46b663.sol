pragma solidity ^0.5.11;
import './ERC20.sol';
import './interfaces/IERC20.sol';

contract UniswapERC20 is ERC20 {
  using SafeMath for uint256;

  event SwapAForB(address indexed buyer, uint256 amountSold, uint256 amountBought);
  event SwapBForA(address indexed buyer, uint256 amountSold, uint256 amountBought);
  event AddLiquidity(address indexed provider, uint256 amountTokenA, uint256 amountTokenB);
  event RemoveLiquidity(address indexed provider, uint256 amountTokenA, uint256 amountTokenB);

  struct Reserves {
    uint128 reserveA;
    uint128 reserveB;
  }

  // ERC20 Data
  string public constant name = 'Uniswap V2';
  string public constant symbol = 'UNI-V2';
  uint256 public constant decimals = 18;

  address public tokenA;                // ERC20 token traded on this contract
  address public tokenB;                // ERC20 token traded on this contract
  address public factory;               // factory that created this contract
  Reserves public reserves;             // cached reserve amounts

  bool private rentrancyLock = false;

  modifier nonReentrant() {
    require(!rentrancyLock);
    rentrancyLock = true;
    _;
    rentrancyLock = false;
  }


  constructor(address _tokenA, address _tokenB) public {
    require(address(_tokenA) != address(0) && _tokenB != address(0), 'INVALID_ADDRESS');
    factory = msg.sender;
    tokenA = _tokenA;
    tokenB = _tokenB;
  }


  function () external {}


  function getInputPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
    require(inputReserve > 0 && outputReserve > 0, 'INVALID_VALUE');
    uint256 inputAmountWithFee = inputAmount.mul(997);
    uint256 numerator = inputAmountWithFee.mul(outputReserve);
    uint256 denominator = inputReserve.mul(1000).add(inputAmountWithFee);
    return numerator / denominator;
  }

  //TO: DO msg.sender is wrapper
  function swapAForB(address recipient) public nonReentrant returns (uint256) {
      address _tokenA = tokenA;
      address _tokenB = tokenB;
      Reserves memory _reserves = reserves;
      uint256 newInputReserve = IERC20(_tokenA).balanceOf(address(this));
      uint256 oldInputReserve = uint256(_reserves.reserveA);
      uint256 currentOutputReserve = IERC20(_tokenB).balanceOf(address(this));
      uint256 amountSold = newInputReserve - oldInputReserve;
      uint256 amountBought = getInputPrice(amountSold, oldInputReserve, currentOutputReserve);
      require(IERC20(_tokenB).transfer(recipient, amountBought), "TRANSFER_FAILED");
      uint256 newOutputReserve = currentOutputReserve - amountBought;
      reserves = Reserves({
        reserveA: uint128(newInputReserve),
        reserveB: uint128(newOutputReserve)
      });
      emit SwapAForB(msg.sender, amountSold, amountBought);
      return amountBought;
  }

  //TO: DO msg.sender is wrapper
  function swapBForA(address recipient) public nonReentrant returns (uint256) {
      address _tokenA = tokenA;
      address _tokenB = tokenB;
      Reserves memory _reserves = reserves;
      uint256 newInputReserve = IERC20(_tokenB).balanceOf(address(this));
      uint256 oldInputReserve = uint256(_reserves.reserveB);
      uint256 currentOutputReserve = IERC20(_tokenA).balanceOf(address(this));
      uint256 amountSold = newInputReserve - oldInputReserve;
      uint256 amountBought = getInputPrice(amountSold, oldInputReserve, currentOutputReserve);
      require(IERC20(_tokenA).transfer(recipient, amountBought), "TRANSFER_FAILED");
      uint256 newOutputReserve = currentOutputReserve - amountBought;
      reserves = Reserves({
        reserveA: uint128(newOutputReserve),
        reserveB: uint128(newInputReserve)
      });
      emit SwapBForA(msg.sender, amountSold, amountBought);
      return amountBought;
  }

  function getInputPrice(address inputToken, uint256 amountSold) public view returns (uint256) {
    require(amountSold > 0);
    address _tokenA = address(tokenA);
    address _tokenB = address(tokenB);
    require(inputToken == _tokenA || inputToken == _tokenB);
    address outputToken = _tokenA;
    if(inputToken == _tokenA) {
      outputToken = _tokenB;
    }
    uint256 inputReserve = IERC20(inputToken).balanceOf(address(this));
    uint256 outputReserve = IERC20(outputToken).balanceOf(address(this));
    return getInputPrice(amountSold, inputReserve, outputReserve);
  }


  function addLiquidity(uint256 amountA, uint256 maxTokenB) public nonReentrant returns (uint256) {
    require(amountA > 0);
    uint256 _totalSupply = totalSupply;

    if (_totalSupply > 0) {
      address _tokenA = tokenA;
      address _tokenB = tokenB;
      uint256 reserveA = IERC20(_tokenA).balanceOf(address(this));
      uint256 reserveB = IERC20(_tokenB).balanceOf(address(this));
      uint256 amountB = (amountA.mul(reserveB) / reserveA).add(1);
      uint256 liquidityMinted = amountA.mul(_totalSupply) / reserveA;
      balanceOf[msg.sender] = balanceOf[msg.sender].add(liquidityMinted);
      totalSupply = _totalSupply.add(liquidityMinted);
      require(IERC20(_tokenA).transferFrom(msg.sender, address(this), amountA));
      require(IERC20(_tokenB).transferFrom(msg.sender, address(this), amountB));
      emit AddLiquidity(msg.sender, amountA, amountB);
      emit Transfer(address(0), msg.sender, liquidityMinted);
      return liquidityMinted;

    } else {
      // TODO: figure out how to set this safely (arithemtic or geometric mean?)
      uint256 initialLiquidity = amountA;
      totalSupply = initialLiquidity;
      balanceOf[msg.sender] = initialLiquidity;
      require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA));
      require(IERC20(tokenB).transferFrom(msg.sender, address(this), maxTokenB));
      emit AddLiquidity(msg.sender, amountA, maxTokenB);
      emit Transfer(address(0), msg.sender, initialLiquidity);
      return initialLiquidity;
    }
  }


  function removeLiquidity(uint256 amount) public nonReentrant returns (uint256, uint256) {
    require(amount > 0);
    address _tokenA = tokenA;
    address _tokenB = tokenB;
    uint256 reserveA = IERC20(_tokenA).balanceOf(address(this));
    uint256 reserveB = IERC20(_tokenB).balanceOf(address(this));
    uint256 _totalSupply = totalSupply;
    uint256 tokenAAmount = amount.mul(reserveA) / _totalSupply;
    uint256 tokenBAmount = amount.mul(reserveB) / _totalSupply;
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
    totalSupply = _totalSupply.sub(amount);
    require(IERC20(_tokenA).transfer(msg.sender, tokenAAmount));
    require(IERC20(_tokenB).transfer(msg.sender, tokenBAmount));
    emit RemoveLiquidity(msg.sender, tokenAAmount, tokenBAmount);
    emit Transfer(msg.sender, address(0), amount);
    return (tokenAAmount, tokenBAmount);
  }
}