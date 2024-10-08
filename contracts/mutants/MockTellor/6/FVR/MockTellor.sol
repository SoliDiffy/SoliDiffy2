
contract MockTellor {

    // --- Mock price data ---

    bool didRetrieve = true; // default to a positive retrieval
    uint private price;
    uint private updateTime;

    // --- Setters for mock price data ---

    function setPrice(uint _price) public returns (bool) {
        price = _price;
    }

      function setDidRetrieve(bool _didRetrieve) public returns (bool) {
        didRetrieve = _didRetrieve;
    }

    function setUpdateTime(uint _updateTime) public returns (bool) {
        updateTime = _updateTime;
    }

    // --- Mock data reporting functions --- 

    function getTimestampbyRequestIDandIndex(uint _requestId, uint _count) public view returns (uint) {
        return updateTime;
    }

    function getNewValueCountbyRequestId(uint reqId) public view returns (uint) {
        return 1;
    }

    function retrieveData(uint256 _requestId, uint256 _timestamp) public view returns (uint256) {
        return price;
    }



}