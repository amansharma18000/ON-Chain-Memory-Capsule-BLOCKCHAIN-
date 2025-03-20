// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MemoryCapsule {
    // Structure to store memory data
    struct Memory {
        string message;
        uint256 unlockTime;
        bool exists;
    }

    // Mapping from address to their memory
    mapping(address => Memory) public memories;
    
    // Events
    event MemoryStored(address indexed creator, uint256 unlockTime);
    event MemoryRevealed(address indexed creator, string message);
    
    // Store a new memory with a time lock
    function storeMemory(string memory _message, uint256 _unlockTimeInDays) public {
        require(!memories[msg.sender].exists, "You already have a stored memory");
        
        // Calculate unlock time based on current time + days
        uint256 unlockTime = block.timestamp + (_unlockTimeInDays * 1 days);
        
        // Store the memory
        memories[msg.sender] = Memory({
            message: _message,
            unlockTime: unlockTime,
            exists: true
        });
        
        emit MemoryStored(msg.sender, unlockTime);
    }
    
    // Reveal memory if time lock has expired
    function revealMemory() public view returns (string memory) {
        Memory storage memory_ = memories[msg.sender];
        
        require(memory_.exists, "No memory found for this address");
        require(block.timestamp >= memory_.unlockTime, "Memory is still time-locked");
        
        return memory_.message;
    }
    
    // Check time remaining until unlock
    function timeRemaining() public view returns (uint256) {
        Memory storage memory_ = memories[msg.sender];
        
        require(memory_.exists, "No memory found for this address");
        
        if (block.timestamp >= memory_.unlockTime) {
            return 0;
        }
        
        return memory_.unlockTime - block.timestamp;
    }
    
    // Delete memory after revealing
    function deleteMemory() public {
        Memory storage memory_ = memories[msg.sender];
        
        require(memory_.exists, "No memory found for this address");
        require(block.timestamp >= memory_.unlockTime, "Memory is still time-locked");
        
        delete memories[msg.sender];
    }
}