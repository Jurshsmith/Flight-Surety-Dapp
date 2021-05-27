pragma solidity ^0.4.25;

contract FlightSuretyFlightData {
    struct Flight {
        bool isRegistered;
        bytes32 flight;
        address airline;
        int8 statusCode;
        uint256 updatedTimestamp;
    }
    mapping(bytes32 => Flight) public flights;

    struct FlightInsurance {
        mapping(address => Flight) flights;
        uint256 amountInsured;
    }

    /**
     * @dev Register a future flight for insuring.
     *
     */
    function registerFlight(bytes32 flight) external returns (bytes32) {
        bytes32 flightKey = getFlightKey(msg.sender, flight, now);
        flights[flightKey] = Flight(true, flight, msg.sender, 0, now);
        return flightKey;
    }

    /**
     * @dev Unique random key to register each flight. Serves as a flight id
     *
     */
    function getFlightKey(
        address airline,
        bytes32 flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }
}
