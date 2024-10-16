pragma solidity ^0.4.23;

contract DutchUtils {

  function getSelectors() external pure returns (bytes4[] memory selectors) {
    selectors = new bytes4[](13);

    selectors[0] = this.initializeCrowdsale.selector;
    selectors[1] = this.finalizeCrowdsale.selector;
    selectors[2] = this.updateGlobalMinContribution.selector;
    selectors[3] = this.whitelistMulti.selector;
    selectors[4] = this.setCrowdsaleStartandDuration.selector;
    selectors[5] = this.initCrowdsaleToken.selector;
    selectors[6] = this.setTransferAgentStatus.selector;

    selectors[7] = this.buy.selector;

    selectors[8] = bytes4(keccak256('transfer(address,uint256)'));
    selectors[9] = this.transferFrom.selector;
    selectors[10] = this.approve.selector;
    selectors[11] = this.increaseApproval.selector;
    selectors[12] = this.decreaseApproval.selector;
  }

  // Admin
  function initializeCrowdsale() external pure returns (bytes) { return msg.data; }
  function finalizeCrowdsale() external pure returns (bytes) { return msg.data; }
  function updateGlobalMinContribution(uint) external pure returns (bytes) { return msg.data; }
  function whitelistMulti(address[], uint[], uint[]) external pure returns (bytes) { return msg.data; }
  function setCrowdsaleStartandDuration(uint, uint) external pure returns (bytes) { return msg.data; }
  function initCrowdsaleToken(bytes32, bytes32, uint) external pure returns (bytes) { return msg.data; }
  function setTransferAgentStatus(address, bool) external pure returns (bytes) { return msg.data; }

  // Sale
  function buy() external pure returns (bytes) { return msg.data; }

  // Token
  function transfer(address, uint) external pure returns (bytes) { return msg.data; }
  function transferFrom(address, address, uint) public pure returns (bytes) { return msg.data; }
  function approve(address, uint) public pure returns (bytes) { return msg.data; }
  function increaseApproval(address, uint) public pure returns (bytes) { return msg.data; }
  function decreaseApproval(address, uint) public pure returns (bytes) { return msg.data; }

  function init(
    address, uint, uint, uint, uint, uint, uint, bool, address, bool
  ) public pure returns (bytes memory) {
    return msg.data;
  }
}
