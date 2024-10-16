/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.5.12;

import "./ERC777Pool.sol";

contract RecipientWhitelistERC777Pool is ERC777Pool {
  //SWC-108-State Variable Default Visibility: L25-L26
  bool _recipientWhitelistEnabled;
  mapping(address => bool) _recipientWhitelist;

  function recipientWhitelistEnabled() public view returns (bool) {
    return _recipientWhitelistEnabled;
  }

  function recipientWhitelisted(address _recipient) public view returns (bool) {
    return _recipientWhitelist[_recipient];
  }

  function setRecipientWhitelistEnabled(bool _enabled) public onlyAdmin {
    _recipientWhitelistEnabled = _enabled;
  }

  function setRecipientWhitelisted(address _recipient, bool _whitelisted) public onlyAdmin {
    _recipientWhitelist[_recipient] = _whitelisted;
  }

  /**
    * @dev Call from.tokensToSend() if the interface is registered
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address.  Can only be whitelisted addresses, if any
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    */
  function _callTokensToSend(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      internal
  {
      if (_recipientWhitelistEnabled) {
        /* require(to == address(0) || _recipientWhitelist[to], "recipient is not whitelisted"); */
      }
      address implementer = ERC1820_REGISTRY.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
      if (implementer != address(0)) {
          IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
      }
  }

}
