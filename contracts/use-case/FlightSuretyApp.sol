pragma solidity ^0.4.25;

import "../data/FlightSuretyData.sol";
import "./FlightSuretyBaseAppWithAccessControl.sol";

import "./FlightSuretyAirlineController.sol";
import "./FlightSuretyFlightController.sol";

contract FlightSuretyApp is
    FlightSuretyAirlineController,
    FlightSuretyFlightController
{}
