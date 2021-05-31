pragma solidity ^0.4.25;

import "./FlightSuretyDataAccessControl.sol";

contract FlightSuretyFlightsData is FlightSuretyDataAccessControl {
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
    function registerFlight(
        address airlineAddress,
        bytes32 flight,
        uint8 statusCode
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        returns (bytes32, uint256)
    {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, now);
        flights[flightKey] = Flight(
            true,
            flight,
            airlineAddress,
            statusCode,
            now
        );
        return (flightKey, now);
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

    function setFlightStatus(bytes32 flightKey, uint8 statusCode)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        flights[flightKey].statusCode = statusCode;
    }
}
