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
        uint8 statusCode,
        uint256 timestamp,
        bytes32 flightKey
    ) external requireAuthorizedAddress requireIsOperational {
        flights[flightKey] = Flight(
            true,
            flight,
            airlineAddress,
            statusCode,
            timestamp
        );
    }

    function setFlightStatus(bytes32 flightKey, uint8 statusCode)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        flights[flightKey].statusCode = statusCode;
    }
}
