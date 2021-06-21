pragma solidity ^0.4.26;

import "./FlightSuretyAirlineController.sol";
import "./FlightSuretyFlightController.sol";
import "./FlightSuretyPassengerController.sol";

contract FlightSuretyApp is
    FlightSuretyAirlineController,
    FlightSuretyFlightController,
    FlightSuretyPassengerController
{
    constructor(address dataContractAddress) public {
        flightSuretyDataContractAddress = dataContractAddress;
        flightSuretyData = FlightSuretyData(dataContractAddress);
    }

    function initializationActions(address firstAirline)
        external
        requireContractOwner
    {
        // should be done after this contract has been authorized
        flightSuretyData.registerAirline(firstAirline);
    }
}
