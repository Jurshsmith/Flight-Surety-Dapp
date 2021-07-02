pragma solidity ^0.4.26;

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
     * @dev Fallback pay function.
     *
     */
    function() public payable {}
}
