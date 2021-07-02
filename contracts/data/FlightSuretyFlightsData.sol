pragma solidity ^0.4.26;

import "./FlightSuretyDataAccessControl.sol";

contract FlightSuretyFlightsData is FlightSuretyDataAccessControl {
    struct FlightModel {
        bool isRegistered;
        bytes32 flightName;
        address airline;
        uint8 statusCode;
        uint256 updatedTimestamp;
        mapping(address => uint256) passengers; // also tracks the passenger balance based on the address and amount insured
    }

    mapping(bytes32 => FlightModel) public flights;

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

    /**
     * @dev Set Flight status
     *      
     *
     */
    function setFlightStatus(bytes32 flightKey, uint8 statusCode)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        flights[flightKey].statusCode = statusCode;
    }

    /**
     * @dev Set amount insured by flight from flights mapping
     *      
     *
     */
    function setAmountInsuredByRegisteredInAFlight(
        bytes32 flightKey,
        address passengerAddress,
        uint256 amountInsured
    ) external requireAuthorizedAddress requireIsOperational {
        flights[flightKey].passengers[passengerAddress] = amountInsured;
    }

    /**
     * @dev Get flight status code from flights mapping
     *      
     *
     */
    function getFlightStatusCode(bytes32 flightKey)
        external
        view
        requireAuthorizedAddress
        returns (uint8)
    {
        return flights[flightKey].statusCode;
    }

    /**
     * @dev get passengerBalance per flight
     *
     */
    function getPassengerBalanceFromThisFlight(
        bytes32 flightKey,
        address passengerAddress
    ) external view requireAuthorizedAddress returns (uint256) {
        return flights[flightKey].passengers[passengerAddress];
    }

    /**
     * @dev Get airline that created flight
     *
     */
    function getAirlineThatCreatedFlight(bytes32 flightKey)
        external
        view
        requireAuthorizedAddress
        returns (address)
    {
        return flights[flightKey].airline;
    }
}
