pragma solidity 0.4.23;

import '../BoomstarterICO.sol';

/// @title Helper for unit-testing BoomstarterICO - DONT use in production!
contract BoomstarterICOTestHelper is BoomstarterICO {

    function BoomstarterICOTestHelper(
        address[] _owners,
        address _token,
        bool _production
    )
        internal
        BoomstarterICO(_owners, _token, 5, _production)
    {
        m_ETHPriceInCents = 300*100; // $300
        m_leeway = 0; // no offset
    }

    function setTime(uint time) external {
        m_time = time;
    }

    function getTime() public view returns (uint) {
        return m_time;
    }

    function setMaximumTokensSold(uint amount) external {
      c_maximumTokensSold = amount;
    }

    function setCap(uint cap) external {
      c_softCapUsd = cap;
    }

    uint public m_time;
}
