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

pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;

import "@0x/contracts-exchange-libs/contracts/src/LibZeroExTransaction.sol";
import "./libs/LibConstants.sol";
import "./interfaces/ICoordinatorCore.sol";
import "./interfaces/ICoordinatorApprovalVerifier.sol";


contract MixinCoordinatorCore is
    LibConstants,
    ICoordinatorApprovalVerifier,
    ICoordinatorCore
{
    /// @dev Executes a 0x transaction that has been signed by the feeRecipients that correspond to each order in the transaction's Exchange calldata.
    /// @param transaction 0x transaction containing salt, signerAddress, and data.
    /// @param txOrigin Required signer of Ethereum transaction calling this function.
    /// @param transactionSignature Proof that the transaction has been signed by the signer.
    /// @param approvalExpirationTimeSeconds Array of expiration times in seconds for which each corresponding approval signature expires.
    /// @param approvalSignatures Array of signatures that correspond to the feeRecipients of each order in the transaction's Exchange calldata.
    function executeTransaction(
        LibZeroExTransaction.ZeroExTransaction storage transaction,
        address txOrigin,
        bytes storage transactionSignature,
        uint256[] storage approvalExpirationTimeSeconds,
        bytes[] storage approvalSignatures
    )
        public
    {
        // Validate that the 0x transaction has been approves by each feeRecipient
        assertValidCoordinatorApprovals(
            transaction,
            txOrigin,
            transactionSignature,
            approvalExpirationTimeSeconds,
            approvalSignatures
        );

        // Execute the transaction
        EXCHANGE.executeTransaction(transaction, transactionSignature);
    }
}
