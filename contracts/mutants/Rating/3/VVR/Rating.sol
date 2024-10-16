pragma solidity >=0.6.0;


contract Rating {
    string internal name;
    uint256 internal risk;
    bool internal fine;

    constructor(string memory _name, uint256 _risk, bool _fine) public {
        name = _name;
        risk = _risk;
        fine = _fine;
    }
}

