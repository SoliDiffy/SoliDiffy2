// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

import "./TokenListener.sol";

contract UnsafeTokenListenerDelegator is TokenListener, Initializable {

  event Initialized(TokenListenerInterface unsafeTokenListener);

  TokenListenerInterface public unsafeTokenListener;

  function initialize (TokenListenerInterface _unsafeTokenListener) external initializer {
    unsafeTokenListener = _unsafeTokenListener;

    emit Initialized(unsafeTokenListener);
  }

  /// @notice Called when tokens are minted.
  /// @param to The address of the receiver of the minted tokens.
  /// @param amount The amount of tokens being minted
  /// @param controlledToken The address of the token that is being minted
  /// @param referrer The address that referred the minting.
  

  /// @notice Called when tokens are transferred or burned.
  /// @param from The address of the sender of the token transfer
  /// @param to The address of the receiver of the token transfer.  Will be the zero address if burning.
  /// @param amount The amount of tokens transferred
  /// @param controlledToken The address of the token that was transferred
  

}