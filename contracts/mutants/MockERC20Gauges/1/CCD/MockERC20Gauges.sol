// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20Gauges, ERC20, Auth, Authority} from "../../token/ERC20Gauges.sol";

contract MockERC20Gauges is ERC20Gauges {
    

    function mint(address to, uint256 value) public virtual {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual {
        _burn(from, value);
    }
}
