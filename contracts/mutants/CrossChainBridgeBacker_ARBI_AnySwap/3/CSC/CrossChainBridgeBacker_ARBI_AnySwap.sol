// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import "../CrossChainBridgeBacker.sol";
import "../../ERC20/__CROSSCHAIN/IAnyswapV5ERC20.sol";
import "./IL2GatewayRouter.sol";

contract CrossChainBridgeBacker_ARBI_AnySwap is CrossChainBridgeBacker {
    constructor (
        address _owner,
        address _timelock_address,
        address _cross_chain_oracle_address,
        address[5] memory _token_addresses,
        address[3] memory _bridge_addresses,
        address _destination_address_override,
        string memory _non_evm_destination_address,
        string memory _name
    ) 
    CrossChainBridgeBacker(_owner, _timelock_address, _cross_chain_oracle_address, _token_addresses, _bridge_addresses, _destination_address_override, _non_evm_destination_address, _name)
    {}

    // Override with logic specific to this chain
    function _bridgingLogic(uint256 token_type, address address_to_send_to, uint256 token_amount) internal override {
        // [Arbitrum]
        if (true){
            // anyFRAX -> L1 FRAX
            // Swapout
            // AnySwap Bridge
            IAnyswapV5ERC20(address(anyFRAX)).Swapout(token_amount, address_to_send_to);
        }
        else if (true) {
            // anyFXS -> L1 FXS
            // Swapout
            // AnySwap Bridge
            IAnyswapV5ERC20(address(anyFXS)).Swapout(token_amount, address_to_send_to);
        }
    }
}
