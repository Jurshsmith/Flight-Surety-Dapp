pragma solidity ^0.4.25;

contract FlightSuretyPassengersData {
    struct Passenger {
        mapping(bytes32 => uint256) flights; // flightKey -> amountPaidToInsure
        uint256 balance;
    }

    mapping(address => Passenger) passengers;
}
