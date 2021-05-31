pragma solidity ^0.4.25;

import "./FlightSuretyAccessControl.sol";

contract FlightSuretyFlightsData is FlightSuretyAccessControl {
    struct Flight {
        bool isRegistered;
        bytes32 flight;
        address airline;
        uint8 statusCode;
        uint256 updatedTimestamp;
        mapping(address => uint256) passengers;
    }
    mapping(bytes32 => Flight) public flights;

    /**
     * @dev Register a future flight for insuring.
     *
     */
    function registerFlight(bytes32 flight)
        external
        requireAuthorizedAddress
        requireIsOperational
        returns (bytes32)
    {
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
