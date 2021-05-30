pragma solidity ^0.4.25;

import "./FlightSuretyFlightsData.sol";
import "./FlightSuretyOraclesData.sol";
import "./FlightSuretyAirlinesData.sol";
import "./FlightSuretyPassengersData.sol";

contract FlightSuretyData is
    FlightSuretyFlightsData,
    FlightSuretyOraclesData,
    FlightSuretyAirlinesData,
    FlightSuretyPassengersData
{
    /**
     * @dev Fallback function for funding smart contract.
     *
     */
    function() external payable {}
}
