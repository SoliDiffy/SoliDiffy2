// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

/*
    Converter Upgrader interface
*/
interface IConverterUpgrader {
    
    function upgrade(uint16 _version) external;
}
