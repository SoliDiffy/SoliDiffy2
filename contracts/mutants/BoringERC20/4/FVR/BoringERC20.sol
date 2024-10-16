// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IERC20Permit.sol";

library BoringERC20 {
    functiofunction safeSymbol(IERC20 token) public view returns (string memory)    (bool success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safefunction safeName(IERC20 token) public view returns (string memory) ol success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimafunction safeDecimals(IERC20 token) public view returns (uint8) cess, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
  function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) public s memory data) =
            address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "BoringERC20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) =
            address(token).call(
                abi.encodeWithSelector(0x23b872dd, from, to, amount)
            );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "BoringERC20: TransferFrom failed"
        );
    }
}
