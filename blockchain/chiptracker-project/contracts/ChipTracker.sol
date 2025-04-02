// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ChipTracker {
    // Structure to hold the details of each silicon chip.
    struct Chip {
        string uid;             // Unique identifier for the chip (e.g., a UUID)
        uint256 manufactureDate;// Timestamp when the chip was manufactured
        uint256 disposalDate;   // Timestamp when the chip was disposed
        uint256 transferDate;   // Timestamp when the chip was transferred for reuse
        address manufacturer;   // Address of the original manufacturer
        address disposer;       // Address that recorded the disposal event
        address newManufacturer;// Address of the new manufacturer for reuse
        string status;          // Current status of the chip: "Manufactured", "Disposed", "Transferred for Reuse"
    }
    
    // Mapping to store chip details using the UID as the key.
    mapping(string => Chip) public chips;
    
    // Events to log each stage of the chip lifecycle.
    event ChipRegistered(string indexed uid, address indexed manufacturer, uint256 manufactureDate);
    event ChipDisposed(string indexed uid, address indexed disposer, uint256 disposalDate);
    event ChipTransferred(string indexed uid, address indexed newManufacturer, uint256 transferDate);
    
    /**
     * @dev Registers a new chip.
     * @param _uid Unique identifier for the chip.
     * @param _manufactureDate Timestamp when the chip was manufactured.
     */
    function registerChip(string memory _uid, uint256 _manufactureDate) public {
        require(bytes(_uid).length > 0, "UID must not be empty");
        require(chips[_uid].manufactureDate == 0, "Chip already registered");
        
        chips[_uid] = Chip({
            uid: _uid,
            manufactureDate: _manufactureDate,
            disposalDate: 0,
            transferDate: 0,
            manufacturer: msg.sender,
            disposer: address(0),
            newManufacturer: address(0),
            status: "Manufactured"
        });
        
        emit ChipRegistered(_uid, msg.sender, _manufactureDate);
    }
    
    /**
     * @dev Records the disposal of a chip.
     * @param _uid Unique identifier for the chip.
     * @param _disposalDate Timestamp when the chip was disposed.
     */
    function recordDisposal(string memory _uid, uint256 _disposalDate) public {
        require(chips[_uid].manufactureDate != 0, "Chip not registered");
        require(chips[_uid].disposalDate == 0, "Chip already disposed");
        
        chips[_uid].disposalDate = _disposalDate;
        chips[_uid].disposer = msg.sender;
        chips[_uid].status = "Disposed";
        
        emit ChipDisposed(_uid, msg.sender, _disposalDate);
    }
    
    /**
     * @dev Records the transfer of a disposed chip for reuse by another manufacturer.
     * @param _uid Unique identifier for the chip.
     * @param _transferDate Timestamp when the chip was transferred.
     * @param _newManufacturer Address of the new manufacturer receiving the chip.
     */
    function recordTransferForReuse(string memory _uid, uint256 _transferDate, address _newManufacturer) public {
        require(chips[_uid].disposalDate != 0, "Chip not disposed yet");
        require(chips[_uid].transferDate == 0, "Chip already transferred");
        require(_newManufacturer != address(0), "Invalid new manufacturer address");
        
        chips[_uid].transferDate = _transferDate;
        chips[_uid].newManufacturer = _newManufacturer;
        chips[_uid].status = "Transferred for Reuse";
        
        emit ChipTransferred(_uid, _newManufacturer, _transferDate);
    }
}
