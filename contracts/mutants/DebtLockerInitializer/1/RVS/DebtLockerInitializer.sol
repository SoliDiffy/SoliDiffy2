// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.7;

import { IMapleLoanLike }  from "./interfaces/Interfaces.sol";

import { DebtLockerStorage } from "./DebtLockerStorage.sol";

/// @title DebtLockerInitializer is intended to initialize the storage of a DebtLocker proxy.
contract DebtLockerInitializer is DebtLockerStorage {

    function encodeArguments(address loan_, address pool_) external pure returns (bytes memory encodedArguments_) {
        return abi.encode(loan_, pool_);
    }

    function decodeArguments(bytes calldata encodedArguments_) public pure returns (address pool_, address loan_) {
        ( loan_, pool_ ) = abi.decode(encodedArguments_, (address, address));
    }

    fallback() external {
        ( address loan_, address pool_ ) = decodeArguments(msg.data);

        _loan = loan_;
        _pool = pool_;

        _principalRemainingAtLastClaim = IMapleLoanLike(loan_).principalRequested();
    }

}
