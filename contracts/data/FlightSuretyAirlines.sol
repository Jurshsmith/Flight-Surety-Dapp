pragma solidity >=0.4.25;

// Lessons
// The data should be like you are designing a database. It's designed as a persisting layer
// use enum in place of string
//Storage, Memory, stack is the place where the variable is stored, Local/State defines both scope and the place in solidity
contract FlightSuretyAirlines {
    struct PreRegisteredAirline {
        int256 votes;
    }

    struct RegisteredAirline {
        uint256 amountPaid;
    }

    mapping(address => RegisteredAirline) internal registeredAirlines;
    int256 internal registeredAirlineLength = 0;

    mapping(address => PreRegisteredAirline) internal preRegisteredAirlines;
    int256 internal preRegisteredAirlineLength = 0;

    constructor() public {
        registeredAirlines[msg.sender] = RegisteredAirline(0);
        registeredAirlineLength++;
    }
}
