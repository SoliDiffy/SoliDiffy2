pragma solidity ^0.4.23;

import '../lib/SafeMath.sol';

library Contract {

  using SafeMath for uint;

  // Modifiers: //

  // Runs two functions before and after a function -
  modifier conditions(function () pure first, function () pure last) {
    first();
    _;
    last();
  }

  bytes32 internal constant EXEC_PERMISSIONS = sha256('script_exec_permissions');

  // Sets up contract execution - reads execution id and sender from storage and
  // places in memory, creating getters. Calling this function should be the first
  // action an application does as part of execution, as it sets up memory for
  // execution. Additionally, application functions in the main file should be
  // external, so that memory is not touched prior to calling this function.
  // The 3rd slot allocated will hold a pointer to a storage buffer, which will
  // be reverted to abstract storage to store data, emit events, and forward
  // wei on behalf of the application.
  function authorize(address _script_exec) internal view {
    // No memory should have been allocated yet - expect the free memory pointer
    // to point to 0x80 - and throw if it does not
    require(freeMem() == 0x80, "Memory allocated prior to execution");
    // Next, set up memory for execution
    bytes32 perms = EXEC_PERMISSIONS;
    assembly {
      mstore(0x80, sload(0))     // Execution id, read from storage
      mstore(0xa0, sload(1))     // Original sender address, read from storage
      mstore(0xc0, 0)            // Pointer to storage buffer
      mstore(0xe0, 0)            // Bytes4 value of the current action requestor being used
      mstore(0x100, 0)           // Enum representing the next type of function to be called (when pushing to buffer)
      mstore(0x120, 0)           // Number of storage slots written to in buffer
      mstore(0x140, 0)           // Number of events pushed to buffer
      mstore(0x160, 0)           // Number of payment destinations pushed to buffer

      // Update free memory pointer -
      mstore(0x40, 0x180)
    }
    // Ensure that the sender and execution id returned from storage are nonzero -
    assert(execID() != bytes32(0) && sender() != address(0));

    // Check that the sender is authorized as a script exec contract for this exec id
    bool authorized;
    assembly {
      // Place the script exec address at 0, and the exec permissions seed after it
      mstore(0, _script_exec)
      mstore(0x20, perms)
      // Hash the resulting 0x34 bytes, and place back into memory at 0
      mstore(0, keccak256(0x0c, 0x34))
      // Place the exec id after the hash -
      mstore(0x20, mload(0x80))
      // Hash the previous hash with the execution id, and check the result
      authorized := sload(keccak256(0, 0x40))
    }
    if (!authorized)
      revert("Sender is not authorized as a script exec address");
  }

  // Sets up contract execution when initializing an instance of the application
  // First, reads execution id and sender from storage (execution id should be 0xDEAD),
  // then places them in memory, creating getters. Calling this function should be the first
  // action an application does as part of execution, as it sets up memory for
  // execution. Additionally, application functions in the main file should be
  // external, so that memory is not touched prior to calling this function.
  // The 3rd slot allocated will hold a pointer to a storage buffer, which will
  // be reverted to abstract storage to store data, emit events, and forward
  // wei on behalf of the application.
  function initialize() internal view {
    // No memory should have been allocated yet - expect the free memory pointer
    // to point to 0x80 - and throw if it does not
    require(freeMem() == 0x80, "Memory allocated prior to execution");
    // Next, set up memory for execution
    assembly {
      mstore(0x80, sload(0))     // Execution id, read from storage
      mstore(0xa0, sload(1))     // Original sender address, read from storage
      mstore(0xc0, 0)            // Pointer to storage buffer
      mstore(0xe0, 0)            // Bytes4 value of the current action requestor being used
      mstore(0x100, 0)           // Enum representing the next type of function to be called (when pushing to buffer)
      mstore(0x120, 0)           // Number of storage slots written to in buffer
      mstore(0x140, 0)           // Number of events pushed to buffer
      mstore(0x160, 0)           // Number of payment destinations pushed to buffer

      // Update free memory pointer -
      mstore(0x40, 0x180)
    }
    // Ensure that the sender and execution id returned from storage are expected values -
    assert(execID() != bytes32(0) && sender() != address(0));
  }

  // Calls the passed-in function, performing a memory state check before and after the check
  // is executed.
  function checks(function () view _check) conditions(validState, validState) internal view {
    _check();
  }

  // Calls the passed-in function, performing a memory state check before and after the check
  // is executed.
  function checks(function () pure _check) conditions(validState, validState) internal pure {
    _check();
  }

  // Ensures execution completed successfully, and reverts the created storage buffer
  // back to the sender.
  function commit() conditions(validState, none) internal pure {
    // Check value of storage buffer pointer - should be at least 0x180
    bytes32 ptr = buffPtr();
    require(ptr >= 0x180, "Invalid buffer pointer");

    assembly {
      // Get the size of the buffer
      let size := mload(add(0x20, ptr))
      mstore(ptr, 0x20) // Place dynamic data offset before buffer
      // Revert to storage
      revert(ptr, add(0x40, size))
    }
  }

  // Helpers: //

  // Checks to ensure the application was correctly executed -
  function validState() private pure {
    if (freeMem() < 0x180)
      revert('Expected Contract.execute()');

    if (buffPtr() != 0 && buffPtr() < 0x180)
      revert('Invalid buffer pointer');

    assert(execID() != bytes32(0) && sender() != address(0));
  }

  // Returns a pointer to the execution storage buffer -
  function buffPtr() private pure returns (bytes32 ptr) {
    assembly { ptr := mload(0xc0) }
  }

  // Returns the location pointed to by the free memory pointer -
  function freeMem() private pure returns (bytes32 ptr) {
    assembly { ptr := mload(0x40) }
  }

  // Returns the current storage action
  function currentAction() private pure returns (bytes4 action) {
    if (buffPtr() == bytes32(0))
      return bytes4(0);

    assembly { action := mload(0xe0) }
  }

  // If the current action is not storing, reverts
  function isStoring() private pure {
    if (currentAction() != STORES)
      revert('Invalid current action - expected STORES');
  }

  // If the current action is not emitting, reverts
  function isEmitting() private pure {
    if (currentAction() != EMITS)
      revert('Invalid current action - expected EMITS');
  }

  // If the current action is not paying, reverts
  function isPaying() private pure {
    if (currentAction() != PAYS)
      revert('Invalid current action - expected PAYS');
  }

  // Initializes a storage buffer in memory -
  function startBuffer() private pure {
    assembly {
      // Get a pointer to free memory, and place at 0xc0 (storage buffer pointer)
      let ptr := msize()
      mstore(0xc0, ptr)
      // Clear bytes at pointer -
      mstore(ptr, 0)            // temp ptr
      mstore(add(0x20, ptr), 0) // buffer length
      // Update free memory pointer -
      mstore(0x40, add(0x40, ptr))
      // Set expected next function to 'NONE' -
      mstore(0x100, 1)
    }
  }

  // Checks whether or not it is valid to create a STORES action request -
  function validStoreBuff() private pure {
    // Get pointer to current buffer - if zero, create a new buffer -
    if (buffPtr() == bytes32(0))
      startBuffer();

    // Ensure that the current action is not 'storing', and that the buffer has not already
    // completed a STORES action -
    if (stored() != 0 || currentAction() == STORES)
      revert('Duplicate request - stores');
  }

  // Checks whether or not it is valid to create an EMITS action request -
  function validEmitBuff() private pure {
    // Get pointer to current buffer - if zero, create a new buffer -
    if (buffPtr() == bytes32(0))
      startBuffer();

    // Ensure that the current action is not 'emitting', and that the buffer has not already
    // completed an EMITS action -
    if (emitted() != 0 || currentAction() == EMITS)
      revert('Duplicate request - emits');
  }

  // Checks whether or not it is valid to create a PAYS action request -
  function validPayBuff() private pure {
    // Get pointer to current buffer - if zero, create a new buffer -
    if (buffPtr() == bytes32(0))
      startBuffer();

    // Ensure that the current action is not 'paying', and that the buffer has not already
    // completed an PAYS action -
    if (paid() != 0 || currentAction() == PAYS)
      revert('Duplicate request - pays');
  }

  // Placeholder function when no pre or post condition for a function is needed
  function none() private pure { }

  // Runtime getters: //

  // Returns the execution id from memory -
  function execID() internal pure returns (bytes32 exec_id) {
    assembly { exec_id := mload(0x80) }
    require(exec_id != bytes32(0), "Execution id overwritten, or not read");
  }

  // Returns the original sender from memory -
  function sender() internal pure returns (address addr) {
    assembly { addr := mload(0xa0) }
    require(addr != address(0), "Sender address overwritten, or not read");
  }

  // Reading from storage: //

  // Reads from storage, resolving the passed-in location to its true location in storage
  // by hashing with the exec id. Returns the data read from that location
  function read(bytes32 _location) internal view returns (bytes32 data) {
    data = keccak256(_location, execID());
    assembly { data := sload(data) }
  }

  // Storing data, emitting events, and forwarding payments: //

  bytes4 internal constant EMITS = bytes4(keccak256('Emit((bytes32[],bytes)[])'));
  bytes4 internal constant STORES = bytes4(keccak256('Store(bytes32[])'));
  bytes4 internal constant PAYS = bytes4(keccak256('Pay(bytes32[])'));
  bytes4 internal constant THROWS = bytes4(keccak256('Error(string)'));

  // Function enums -
  enum NextFunction {
    INVALID, NONE, STORE_DEST, VAL_SET, VAL_INC, VAL_DEC, EMIT_LOG, PAY_DEST, PAY_AMT
  }

  // Checks that a call pushing a storage destination to the buffer is expected and valid
  function validStoreDest() private pure {
    // Ensure that the next function expected pushes a storage destination -
    if (expected() != NextFunction.STORE_DEST)
      revert('Unexpected function order - expected storage destination to be pushed');

    // Ensure that the current buffer is pushing STORES actions -
    isStoring();
  }

  // Checks that a call pushing a storage value to the buffer is expected and valid
  function validStoreVal() private pure {
    // Ensure that the next function expected pushes a storage value -
    if (
      expected() != NextFunction.VAL_SET &&
      expected() != NextFunction.VAL_INC &&
      expected() != NextFunction.VAL_DEC
    ) revert('Unexpected function order - expected storage value to be pushed');

    // Ensure that the current buffer is pushing STORES actions -
    isStoring();
  }

  // Checks that a call pushing a payment destination to the buffer is expected and valid
  function validPayDest() private pure {
    // Ensure that the next function expected pushes a payment destination -
    if (expected() != NextFunction.PAY_DEST)
      revert('Unexpected function order - expected payment destination to be pushed');

    // Ensure that the current buffer is pushing PAYS actions -
    isPaying();
  }

  // Checks that a call pushing a payment amount to the buffer is expected and valid
  function validPayAmt() private pure {
    // Ensure that the next function expected pushes a payment amount -
    if (expected() != NextFunction.PAY_AMT)
      revert('Unexpected function order - expected payment amount to be pushed');

    // Ensure that the current buffer is pushing PAYS actions -
    isPaying();
  }

  // Checks that a call pushing an event to the buffer is expected and valid
  function validEvent() private pure {
    // Ensure that the next function expected pushes an event -
    if (expected() != NextFunction.EMIT_LOG)
      revert('Unexpected function order - expected event to be pushed');

    // Ensure that the current buffer is pushing EMITS actions -
    isEmitting();
  }

  // Begins creating a storage buffer - values and locations pushed will be committed
  // to storage at the end of execution
  function storing() conditions(validStoreBuff, isStoring) internal pure {
    bytes4 action_req = STORES;
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push requestor to the end of buffer, as well as to the 'current action' slot -
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(0xe0, action_req)
      // Push '0' to the end of the 4 bytes just pushed - this will be the length of the STORES action
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      // Increment buffer length - 0x24 plus the previous length
      mstore(ptr, add(0x24, mload(ptr)))
      // Set the current action being executed (STORES) -
      // SWC-135-Code With No Effects: L334
      mstore(0xe0, action_req)
      // Set the expected next function - STORE_DEST
      mstore(0x100, 2)
      // Set a pointer to the length of the current request within the buffer
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Sets a passed in location to a value passed in via 'to'
  function set(bytes32 _field) conditions(validStoreDest, validStoreVal) internal pure returns (bytes32) {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage destination to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - VAL_SET
      mstore(0x100, 3)
      // Increment STORES action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of storage slots pushed to -
      mstore(0x120, add(1, mload(0x120)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
    return _field;
  }

  // Sets a previously-passed-in destination in storage to the value
  function to(bytes32, bytes32 _val) conditions(validStoreVal, validStoreDest) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage value to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _val)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - STORE_DEST
      mstore(0x100, 2)
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Sets a previously-passed-in destination in storage to the value
  function to(bytes32 _field, uint _val) internal pure {
    to(_field, bytes32(_val));
  }

  // Sets a previously-passed-in destination in storage to the value
  function to(bytes32 _field, address _val) internal pure {
    to(_field, bytes32(_val));
  }

  // Sets a previously-passed-in destination in storage to the value
  function to(bytes32 _field, bool _val) internal pure {
    to(
      _field,
      _val ? bytes32(1) : bytes32(0)
    );
  }

  function increase(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {
    // Read value stored at the location in storage -
    val = keccak256(_field, execID());
    assembly {
      val := sload(val)
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage destination to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - VAL_INC
      mstore(0x100, 4)
      // Increment STORES action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of storage slots pushed to -
      mstore(0x120, add(1, mload(0x120)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
    return val;
  }

  function decrease(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {
    // Read value stored at the location in storage -
    val = keccak256(_field, execID());
    assembly {
      val := sload(val)
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage destination to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _field)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - VAL_DEC
      mstore(0x100, 5)
      // Increment STORES action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of storage slots pushed to -
      mstore(0x120, add(1, mload(0x120)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
    return val;
  }

  function by(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {
    // Check the expected function type - if it is VAL_INC, perform safe-add on the value
    // If it is VAL_DEC, perform safe-sub on the value
    if (expected() == NextFunction.VAL_INC)
      _amt = _amt.add(uint(_val));
    else if (expected() == NextFunction.VAL_DEC)
      _amt = uint(_val).sub(_amt);
    else
      revert('Expected VAL_INC or VAL_DEC');

    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage value to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _amt)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - STORE_DEST
      mstore(0x100, 2)
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Decreases the value at some field by a maximum amount, and sets it to 0 if there will be underflow
  function byMaximum(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {
    // Check the expected function type - if it is VAL_DEC, set the new amount to the difference of
    // _val and _amt, to a minimum of 0
    if (expected() == NextFunction.VAL_DEC) {
      if (_amt > uint(_val))
        _amt = 0;
      else
        _amt = uint(_val).sub(_amt);
    } else {
      revert('Expected VAL_DEC');
    }

    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push storage value to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _amt)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - STORE_DEST
      mstore(0x100, 2)
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Begins creating an event log buffer - topics and data pushed will be emitted by
  // storage at the end of execution
  function emitting() conditions(validEmitBuff, isEmitting) internal pure {
    bytes4 action_req = EMITS;
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push requestor to the end of buffer, as well as to the 'current action' slot -
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(0xe0, action_req)
      // Push '0' to the end of the 4 bytes just pushed - this will be the length of the EMITS action
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      // Increment buffer length - 0x24 plus the previous length
      mstore(ptr, add(0x24, mload(ptr)))
      // Set the current action being executed (EMITS) -
      mstore(0xe0, action_req)
      // Set the expected next function - EMIT_LOG
      mstore(0x100, 6)
      // Set a pointer to the length of the current request within the buffer
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  function log(bytes32 _data) conditions(validEvent, validEvent) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push 0 to the end of the buffer - event will have 0 topics
      mstore(add(0x20, add(ptr, mload(ptr))), 0)
      // If _data is zero, set data size to 0 in buffer and push -
      if eq(_data, 0) {
        mstore(add(0x40, add(ptr, mload(ptr))), 0)
        // Increment buffer length - 0x40 plus the original length
        mstore(ptr, add(0x40, mload(ptr)))
      }
      // If _data is not zero, set size to 0x20 and push to buffer -
      if iszero(eq(_data, 0)) {
        // Push data size (0x20) to the end of the buffer
        mstore(add(0x40, add(ptr, mload(ptr))), 0x20)
        // Push data to the end of the buffer
        mstore(add(0x60, add(ptr, mload(ptr))), _data)
        // Increment buffer length - 0x60 plus the original length
        mstore(ptr, add(0x60, mload(ptr)))
      }
      // Increment EMITS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of events pushed to buffer -
      mstore(0x140, add(1, mload(0x140)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  function log(bytes32[1] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push 1 to the end of the buffer - event will have 1 topic
      mstore(add(0x20, add(ptr, mload(ptr))), 1)
      // Push topic to end of buffer
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      // If _data is zero, set data size to 0 in buffer and push -
      if eq(_data, 0) {
        mstore(add(0x60, add(ptr, mload(ptr))), 0)
        // Increment buffer length - 0x60 plus the original length
        mstore(ptr, add(0x60, mload(ptr)))
      }
      // If _data is not zero, set size to 0x20 and push to buffer -
      if iszero(eq(_data, 0)) {
        // Push data size (0x20) to the end of the buffer
        mstore(add(0x60, add(ptr, mload(ptr))), 0x20)
        // Push data to the end of the buffer
        mstore(add(0x80, add(ptr, mload(ptr))), _data)
        // Increment buffer length - 0x80 plus the original length
        mstore(ptr, add(0x80, mload(ptr)))
      }
      // Increment EMITS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of events pushed to buffer -
      mstore(0x140, add(1, mload(0x140)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  function log(bytes32[2] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push 2 to the end of the buffer - event will have 2 topics
      mstore(add(0x20, add(ptr, mload(ptr))), 2)
      // Push topics to end of buffer
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      // If _data is zero, set data size to 0 in buffer and push -
      if eq(_data, 0) {
        mstore(add(0x80, add(ptr, mload(ptr))), 0)
        // Increment buffer length - 0x80 plus the original length
        mstore(ptr, add(0x80, mload(ptr)))
      }
      // If _data is not zero, set size to 0x20 and push to buffer -
      if iszero(eq(_data, 0)) {
        // Push data size (0x20) to the end of the buffer
        mstore(add(0x80, add(ptr, mload(ptr))), 0x20)
        // Push data to the end of the buffer
        mstore(add(0xa0, add(ptr, mload(ptr))), _data)
        // Increment buffer length - 0xa0 plus the original length
        mstore(ptr, add(0xa0, mload(ptr)))
      }
      // Increment EMITS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of events pushed to buffer -
      mstore(0x140, add(1, mload(0x140)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  function log(bytes32[3] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push 3 to the end of the buffer - event will have 3 topics
      mstore(add(0x20, add(ptr, mload(ptr))), 3)
      // Push topics to end of buffer
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
      // If _data is zero, set data size to 0 in buffer and push -
      if eq(_data, 0) {
        mstore(add(0xa0, add(ptr, mload(ptr))), 0)
        // Increment buffer length - 0xa0 plus the original length
        mstore(ptr, add(0xa0, mload(ptr)))
      }
      // If _data is not zero, set size to 0x20 and push to buffer -
      if iszero(eq(_data, 0)) {
        // Push data size (0x20) to the end of the buffer
        mstore(add(0xa0, add(ptr, mload(ptr))), 0x20)
        // Push data to the end of the buffer
        mstore(add(0xc0, add(ptr, mload(ptr))), _data)
        // Increment buffer length - 0xc0 plus the original length
        mstore(ptr, add(0xc0, mload(ptr)))
      }
      // Increment EMITS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of events pushed to buffer -
      mstore(0x140, add(1, mload(0x140)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  function log(bytes32[4] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push 4 to the end of the buffer - event will have 4 topics
      mstore(add(0x20, add(ptr, mload(ptr))), 4)
      // Push topics to end of buffer
      mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
      mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
      mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
      mstore(add(0xa0, add(ptr, mload(ptr))), mload(add(0x60, _topics)))
      // If _data is zero, set data size to 0 in buffer and push -
      if eq(_data, 0) {
        mstore(add(0xc0, add(ptr, mload(ptr))), 0)
        // Increment buffer length - 0xc0 plus the original length
        mstore(ptr, add(0xc0, mload(ptr)))
      }
      // If _data is not zero, set size to 0x20 and push to buffer -
      if iszero(eq(_data, 0)) {
        // Push data size (0x20) to the end of the buffer
        mstore(add(0xc0, add(ptr, mload(ptr))), 0x20)
        // Push data to the end of the buffer
        mstore(add(0xe0, add(ptr, mload(ptr))), _data)
        // Increment buffer length - 0xe0 plus the original length
        mstore(ptr, add(0xe0, mload(ptr)))
      }
      // Increment EMITS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of events pushed to buffer -
      mstore(0x140, add(1, mload(0x140)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Begins creating a storage buffer - destinations entered will be forwarded wei
  // before the end of execution
  function paying() conditions(validPayBuff, isPaying) internal pure {
    bytes4 action_req = PAYS;
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push requestor to the end of buffer, as well as to the 'current action' slot -
      mstore(add(0x20, add(ptr, mload(ptr))), action_req)
      mstore(0xe0, action_req)
      // Push '0' to the end of the 4 bytes just pushed - this will be the length of the PAYS action
      mstore(add(0x24, add(ptr, mload(ptr))), 0)
      // Increment buffer length - 0x24 plus the previous length
      mstore(ptr, add(0x24, mload(ptr)))
      // Set the current action being executed (PAYS) -
      mstore(0xe0, action_req)
      // Set the expected next function - PAY_AMT
      mstore(0x100, 8)
      // Set a pointer to the length of the current request within the buffer
      mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Pushes an amount of wei to forward to the buffer
  function pay(uint _amount) conditions(validPayAmt, validPayDest) internal pure returns (uint) {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push payment amount to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _amount)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - PAY_DEST
      mstore(0x100, 7)
      // Increment PAYS action length -
      mstore(
        mload(sub(ptr, 0x20)),
        add(1, mload(mload(sub(ptr, 0x20))))
      )
      // Update number of payment destinations to be pushed to -
      mstore(0x160, add(1, mload(0x160)))
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
    return _amount;
  }

  // Push an address to forward wei to, to the buffer
  function toAcc(uint, address _dest) conditions(validPayDest, validPayAmt) internal pure {
    assembly {
      // Get pointer to buffer length -
      let ptr := add(0x20, mload(0xc0))
      // Push payment destination to the end of the buffer -
      mstore(add(0x20, add(ptr, mload(ptr))), _dest)
      // Increment buffer length - 0x20 plus the previous length
      mstore(ptr, add(0x20, mload(ptr)))
      // Set the expected next function - PAY_AMT
      mstore(0x100, 8)
      // If the free-memory pointer does not point beyond the buffer's current size, update it
      if lt(mload(0x40), add(0x20, add(ptr, mload(ptr)))) {
        mstore(0x40, add(0x20, add(ptr, mload(ptr))))
      }
    }
  }

  // Returns the enum representing the next expected function to be called -
  function expected() private pure returns (NextFunction next) {
    assembly { next := mload(0x100) }
  }

  // Returns the number of events pushed to the storage buffer -
  function emitted() internal pure returns (uint num_emitted) {
    if (buffPtr() == bytes32(0))
      return 0;

    // Load number emitted from buffer -
    assembly { num_emitted := mload(0x140) }
  }

  // Returns the number of storage slots pushed to the storage buffer -
  function stored() internal pure returns (uint num_stored) {
    if (buffPtr() == bytes32(0))
      return 0;

    // Load number stored from buffer -
    assembly { num_stored := mload(0x120) }
  }

  // Returns the number of payment destinations and amounts pushed to the storage buffer -
  function paid() internal pure returns (uint num_paid) {
    if (buffPtr() == bytes32(0))
      return 0;

    // Load number paid from buffer -
    assembly { num_paid := mload(0x160) }
  }
}
