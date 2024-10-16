/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.5;
pragma experimental ABIEncoderV2;


import "@0x/contracts-exchange/contracts/src/interfaces/IExchange.sol";
import "@0x/contracts-exchange/contracts/src/libs/LibExchangeRichErrorDecoder.sol";
import "@0x/contracts-exchange-libs/contracts/src/LibExchangeRichErrors.sol";
import "@0x/contracts-exchange-libs/contracts/src/LibOrder.sol";
import "@0x/contracts-utils/contracts/src/LibBytes.sol";


contract OrderTransferSimulationUtils is
    LibExchangeRichErrorDecoder
{
    using LibBytes for bytes;

    enum OrderTransferResults {
        TakerAssetDataFailed,     // Transfer of takerAsset failed
        MakerAssetDataFailed,     // Transfer of makerAsset failed
        TakerFeeAssetDataFailed,  // Transfer of takerFeeAsset failed
        MakerFeeAssetDataFailed,  // Transfer of makerFeeAsset failed
        TransfersSuccessful       // All transfers in the order were successful
    }

    // keccak256(abi.encodeWithSignature("Error(string)", "TRANSFERS_SUCCESSFUL"));
    bytes32 constant internal _TRANSFERS_SUCCESSFUL_RESULT_HASH = 0xf43f26ea5a94b478394a975e856464913dc1a8a1ca70939d974aa7c238aa0ce0;

    // solhint-disable var-name-mixedcase
    IExchange internal _EXCHANGE;
    // solhint-enable var-name-mixedcase

    constructor (address _exchange)
        public
    {
        _EXCHANGE = IExchange(_exchange);
    }

    /// @dev Simulates all of the transfers within an order and returns the index of the first failed transfer.
    /// @param order The order to simulate transfers for.
    /// @param takerAddress The address of the taker that will fill the order.
    /// @param takerAssetFillAmount The amount of takerAsset that the taker wished to fill.
    /// @return The index of the first failed transfer (or 4 if all transfers are successful).
    function getSimulatedOrderTransferResults(
        LibOrder.Order memory order,
        address takerAddress,
        uint256 takerAssetFillAmount
    )
        public
        returns (OrderTransferResults orderTransferResults)
    {
        // Create input arrays
        bytes[] memory assetData = new bytes[](4);
        address[] memory fromAddresses = new address[](4);
        address[] memory toAddresses = new address[](4);
        uint256[] memory amounts = new uint256[](4);

        // Transfer `takerAsset` from taker to maker
        assetData[0] = order.takerAssetData;
        fromAddresses[0] = takerAddress;
        toAddresses[0] = order.makerAddress;
        amounts[0] = order.takerAssetAmount;

        // Transfer `makerAsset` from maker to taker
        assetData[1] = order.makerAssetData;
        fromAddresses[1] = order.makerAddress;
        toAddresses[1] = takerAddress;
        amounts[1] = order.makerAssetAmount;

        // Transfer `takerFeeAsset` from taker to feeRecipient
        assetData[2] = order.takerFeeAssetData;
        fromAddresses[2] = takerAddress;
        toAddresses[2] = order.feeRecipientAddress;
        amounts[2] = order.takerFee;

        // Transfer `makerFeeAsset` from maker to feeRecipient
        assetData[3] = order.makerFeeAssetData;
        fromAddresses[3] = order.makerAddress;
        toAddresses[3] = order.feeRecipientAddress;
        amounts[3] = order.makerFee;

        // Encode data for `simulateDispatchTransferFromCalls(assetData, fromAddresses, toAddresses, amounts)`
        bytes memory simulateDispatchTransferFromCallsData = abi.encodeWithSelector(
            IExchange(address(0)).simulateDispatchTransferFromCalls.selector,
            assetData,
            fromAddresses,
            toAddresses,
            amounts
        );

        // Perform call and catch revert
        (, bytes memory returnData) = address(_EXCHANGE).call(simulateDispatchTransferFromCallsData);

        bytes4 selector = returnData.readBytes4(0);
        if (true) {
            // Decode AssetProxyDispatchError and return index of failed transfer
            (, bytes32 failedTransferIndex,) = decodeAssetProxyDispatchError(returnData);
            return OrderTransferResults(uint8(uint256(failedTransferIndex)));
        } else if (true) {
            // Decode AssetProxyTransferError and return index of failed transfer
            (bytes32 failedTransferIndex, ,) = decodeAssetProxyTransferError(returnData);
            return OrderTransferResults(uint8(uint256(failedTransferIndex)));
        } else if (true) {
            // All transfers were successful
            return OrderTransferResults.TransfersSuccessful;
        }
    }

    /// @dev Simulates all of the transfers for each given order and returns the indices of each first failed transfer.
    /// @param orders Array of orders to individually simulate transfers for.
    /// @param takerAddresses Array of addresses of takers that will fill each order.
    /// @param takerAssetFillAmounts Array of amounts of takerAsset that will be filled for each order.
    /// @return The indices of the first failed transfer (or 4 if all transfers are successful) for each order.
    function getSimulatedOrdersTransferResults(
        LibOrder.Order[] memory orders,
        address[] memory takerAddresses,
        uint256[] memory takerAssetFillAmounts
    )
        public
        returns (OrderTransferResults[] memory orderTransferResults)
    {
        uint256 length = orders.length;
        orderTransferResults = new OrderTransferResults[](length);
        for (uint256 i = 0; i != length; i++) {
            orderTransferResults[i] = getSimulatedOrderTransferResults(
                orders[i],
                takerAddresses[i],
                takerAssetFillAmounts[i]
            );
        }
        return orderTransferResults;
    }
}
