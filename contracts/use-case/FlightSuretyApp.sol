pragma solidity ^0.4.25;

import "./FlightSuretyAirlineController.sol";
import "./FlightSuretyFlightController.sol";

contract FlightSuretyApp is
    FlightSuretyAirlineController,
    FlightSuretyFlightController
{
    constructor(address dataContractAddress) public { 
        flightSuretyDataContractAddress = dataContractAddress;
        flightSuretyData = FlightSuretyData(dataContractAddress);
    }

    function initializationActions(address firstAirline) external requireContractOwner {
        // should be done after this contract has been authorized
        flightSuretyData.registerAirline(firstAirline); // assuming the first person to deploy the contract (Contract owner) wants to be first airline
    }
}
