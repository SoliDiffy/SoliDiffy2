// SPDX-License-Identifier: MIT
// SWC-135-Code With No Effects: L3-39
pragma solidity ^0.7.0;

import "../auth/AdminAuth.sol";

contract ZrxAllowlist is AdminAuth {
    mapping(address => bool) public zrxAllowlist;
    mapping(address => bool) private nonPayableAddrs;

    constructor() {
        zrxAllowlist[0x6958F5e95332D93D21af0D7B9Ca85B8212fEE0A5] = true;
        zrxAllowlist[0x61935CbDd02287B511119DDb11Aeb42F1593b7Ef] = true;
        zrxAllowlist[0xDef1C0ded9bec7F1a1670819833240f027b25EfF] = true;
        zrxAllowlist[0x080bf510FCbF18b91105470639e9561022937712] = true;

        nonPayableAddrs[0x080bf510FCbF18b91105470639e9561022937712] = true;
    }

    function setAllowlistAddr(address _zrxAddr, bool _state) external onlyOwner {
        zrxAllowlist[_zrxAddr] = _state;
    }

    function isZrxAddr(address _zrxAddr) external view returns (bool) {
        return zrxAllowlist[_zrxAddr];
    }

    function addNonPayableAddr(address _nonPayableAddr) external onlyOwner {
        nonPayableAddrs[_nonPayableAddr] = true;
    }

    function removeNonPayableAddr(address _nonPayableAddr) external onlyOwner {
        nonPayableAddrs[_nonPayableAddr] = false;
    }

    function isNonPayableAddr(address _addr) external view returns (bool) {
        return nonPayableAddrs[_addr];
    }
}
