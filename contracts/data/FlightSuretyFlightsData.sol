pragma solidity ^0.4.26;

import "./FlightSuretyDataAccessControl.sol";

contract FlightSuretyFlightsData is FlightSuretyDataAccessControl {
    struct FlightModel {
        bool isRegistered;
        bytes32 flightName;
        address airline;
        uint8 statusCode;
        uint256 updatedTimestamp;
    }

    mapping(bytes32 => FlightModel) flights;

    /**
     * @dev Register future flights for insuring
     *
     */
    function registerFlight(
        address airlineAddress,
        bytes32 flightName,
        uint8 statusCode,
        uint256 timestamp,
        bytes32 flightKey
    ) external requireAuthorizedAddress requireIsOperational {
        flights[flightKey] = FlightModel({
            isRegistered: true,
            flightName: flightName,
            airline: airlineAddress,
            statusCode: statusCode,
            updatedTimestamp: timestamp
        });
    }

    function setFlightStatus(bytes32 flightKey, uint8 statusCode)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        flights[flightKey].statusCode = statusCode;
    }
}
