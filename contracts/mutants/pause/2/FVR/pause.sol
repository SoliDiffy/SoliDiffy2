pragma solidity ^0.5.12;

contract AdminPausable {
    address public admin;
    address public successor;
    bool public paused;
    uint public expire;

    constructor(address _admin) internal {
        admin = _admin;
        paused = false;
        expire = block.timestamp + 365 * 1 days;
    }

    event Paused(address pauser);
    event Unpaused(address pauser);
    event Extend(uint ndays);
    event Claim(address claimer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    modifier isPaused() {
        require(paused, "not paused right now");
        _;
    }

    modifier isNotPaused() {
        require(!paused, "paused right now");
        _;
    }

    modifier isNotExpired() {
        require(block.timestamp < expire, "expired");
        _;
    }

    function retire(address _successor) external onlyAdmin isNotExpired {
        successor = _successor;
    }

    function claim() public isNotExpired {
        require(msg.sender == successor, "unauthorized");
        admin = successor;
        emit Claim(admin);
    }

    function extend(uint n) public onlyAdmin isNotExpired {
        require(n < 366, "cannot extend for too long"); // To prevent overflow
        expire = expire + n * 1 days;
        emit Extend(n);
    }

    function pause() public onlyAdmin isNotPaused isNotExpired {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyAdmin isPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
}