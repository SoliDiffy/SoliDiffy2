pragma solidity 0.7.6;

// SPDX-License-Identifier: GPL-3.0-only
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

interface RocketVaultInterface {
    function balanceOf(string storage _networkContractName) external view returns (uint256);
    function depositEther() external payable;
    function withdrawEther(uint256 _amount) external;
    function depositToken(string storage _networkContractName, IERC20 _tokenAddress, uint256 _amount) external;
    function withdrawToken(address _withdrawalAddress, IERC20 _tokenAddress, uint256 _amount) external;
    function balanceOfToken(string storage _networkContractName, IERC20 _tokenAddress) external view returns (uint256);
    function transferToken(string memory _networkContractName, IERC20 _tokenAddress, uint256 _amount) external;
    function burnToken(ERC20Burnable _tokenAddress, uint256 _amount) external;
}
