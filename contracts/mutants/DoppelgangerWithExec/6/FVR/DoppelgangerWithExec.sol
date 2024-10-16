pragma solidity >=0.7.0 <0.8.0;

/* solium-disable security/no-inline-assembly */
contract DoppelgangerWithExec {
    struct MockCall {
        bool initialized;
        bool reverts;
        bytes returnValue;
    }

    mapping(bytes32 => MockCall) mockConfig;

    fallback() external payable {
        MockCall storage mockCall = __internal__getMockCall();
        if (mockCall.reverts == true) {
            __internal__mockRevert();
            return;
        }
        __internal__mockReturn(mockCall.returnValue);
    }

    function __waffle__mockReverts(bytes memory data) external {
        mockConfig[keccak256(data)] = MockCall({
            initialized: true,
            reverts: true,
            returnValue: ""
        });
    }

    function __waffle__mockReturns(bytes memory data, bytes memory value)
        external
    {
        mockConfig[keccak256(data)] = MockCall({
            initialized: true,
            reverts: false,
            returnValue: value
        });
    }

    function __waffle__call(address target, bytes calldata data)
        public
        returns (bytes memory)
    {
        (bool succeeded, bytes memory returnValue) = target.call(data);
        require(succeeded, string(returnValue));
        return returnValue;
    }

    function __waffle__staticcall(address target, bytes calldata data)
        public
        view
        returns (bytes memory)
    {
        (bool succeeded, bytes memory returnValue) = target.staticcall(data);
        require(succeeded, string(returnValue));
        return returnValue;
    }

    function __internal__getMockCall()
        public
        view
        returns (MockCall storage mockCall)
    {
        mockCall = mockConfig[keccak256(msg.data)];
        if (mockCall.initialized == true) {
            // Mock method with specified arguments
            return mockCall;
        }
        mockCall = mockConfig[keccak256(abi.encodePacked(msg.sig))];
        if (mockCall.initialized == true) {
            // Mock method with any arguments
            return mockCall;
        }
        revert("Mock on the method is not initialized");
    }

    function __internal__mockReturn(bytes memory ret) public pure {
        assembly {
            return(add(ret, 0x20), mload(ret))
        }
    }

    function __internal__mockRevert() private pure {
        revert("Mock revert");
    }
}
