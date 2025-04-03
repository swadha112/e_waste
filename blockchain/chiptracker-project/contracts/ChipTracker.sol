// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ChipTracker {
    struct Chip {
        string uid;               // Unique identifier for the chip
        uint256 manufactureDate;  // When manufactured
        uint256 disposalDate;     // When disposed
        uint256 disintegrationDate; // When disintegrated
        uint256 transferDate;     // When transferred for reuse
        address manufacturer;     // Original manufacturer
        address disposer;         // Address that recorded disposal
        address newManufacturer;  // Address of new manufacturer
        string status;            // "Manufactured", "Disposed", "Disintegrated", "Transferred for Reuse"
        string disposalLocation;        // e.g. "E-waste Centre"
        string disintegrationLocation;  // e.g. "Naidu Colony, Ghatkopar East, Mumbai, 400075"
        string manufacturerLocation;    // e.g. Address of final manufacturer
    }
    
    mapping(string => Chip) public chips;
    
    // Events for each stage
    event ChipRegistered(string indexed uid, address indexed manufacturer, uint256 manufactureDate);
    event ChipDisposed(string indexed uid, address indexed disposer, uint256 disposalDate, string disposalLocation);
    event ChipDisintegrated(string indexed uid, uint256 disintegrationDate, string disintegrationLocation);
    event ChipTransferred(string indexed uid, address indexed newManufacturer, uint256 transferDate, string manufacturerLocation);
    
    // Register a chip
    function registerChip(string memory _uid, uint256 _manufactureDate) public {
        require(bytes(_uid).length > 0, "UID must not be empty");
        require(chips[_uid].manufactureDate == 0, "Chip already registered");

        chips[_uid] = Chip({
            uid: _uid,
            manufactureDate: _manufactureDate,
            disposalDate: 0,
            disintegrationDate: 0,
            transferDate: 0,
            manufacturer: msg.sender,
            disposer: address(0),
            newManufacturer: address(0),
            status: "Manufactured",
            disposalLocation: "",
            disintegrationLocation: "",
            manufacturerLocation: ""
        });

        emit ChipRegistered(_uid, msg.sender, _manufactureDate);
    }
    
    // Record disposal (with disposal location)
    function recordDisposal(string memory _uid, uint256 _disposalDate, string memory _disposalLocation) public {
        require(chips[_uid].manufactureDate != 0, "Chip not registered");
        require(chips[_uid].disposalDate == 0, "Chip already disposed");

        chips[_uid].disposalDate = _disposalDate;
        chips[_uid].disposalLocation = _disposalLocation;
        chips[_uid].disposer = msg.sender;
        chips[_uid].status = "Disposed";

        emit ChipDisposed(_uid, msg.sender, _disposalDate, _disposalLocation);
    }
    
    // Record disintegration (with disintegration location)
    function recordDisintegration(string memory _uid, uint256 _disintegrationDate, string memory _disintegrationLocation) public {
        require(chips[_uid].disposalDate != 0, "Chip not disposed yet");
        require(chips[_uid].disintegrationDate == 0, "Chip already disintegrated");

        chips[_uid].disintegrationDate = _disintegrationDate;
        chips[_uid].disintegrationLocation = _disintegrationLocation;
        chips[_uid].status = "Disintegrated";

        emit ChipDisintegrated(_uid, _disintegrationDate, _disintegrationLocation);
    }
    
    // Record final transfer to reuse (with manufacturer location)
    function recordTransferForReuse(
        string memory _uid,
        uint256 _transferDate,
        address _newManufacturer,
        string memory _manufacturerLocation
    ) public {
        require(chips[_uid].disintegrationDate != 0, "Chip not disintegrated yet");
        require(chips[_uid].transferDate == 0, "Chip already transferred");
        require(_newManufacturer != address(0), "Invalid manufacturer address");

        chips[_uid].transferDate = _transferDate;
        chips[_uid].newManufacturer = _newManufacturer;
        chips[_uid].manufacturerLocation = _manufacturerLocation;
        chips[_uid].status = "Transferred for Reuse";

        emit ChipTransferred(_uid, _newManufacturer, _transferDate, _manufacturerLocation);
    }
}
