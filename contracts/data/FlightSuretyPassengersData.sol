pragma solidity ^0.4.25;

contract FlightSuretyPassengersData {
    struct Passenger {
        // mapping(address => Flight) Flight;
        uint256 balance;
    }

    mapping(address => Passenger) Passengers;
}
