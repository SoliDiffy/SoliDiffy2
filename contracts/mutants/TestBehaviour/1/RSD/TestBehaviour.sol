pragma solidity >=0.5.0 <0.6.0;

import "../../../../AccountRegistry/epochs/20200106/Behaviour20200106.sol";

/**
  * @title TestBehaviour
  * @author AZTEC
  * @dev Deploys a TestBehaviour
 * Copyright 2020 Spilsbury Holdings Ltd 
 *
 * Licensed under the GNU Lesser General Public Licence, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 **/
contract TestBehaviour is Behaviour20200106 {
    uint256 public epoch = 2;

    function newFeature() pure public returns (string memory) {
        /* return 'new feature'; */
    }
}
