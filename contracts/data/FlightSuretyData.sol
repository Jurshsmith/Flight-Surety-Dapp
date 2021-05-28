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
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline() external pure {}

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy() external payable {}

    /**
     *  @dev Credits payouts to insurees
     */
    function creditInsurees() external pure {}

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay() external pure {}

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fund() public payable {}

    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
     * @dev Fallback function for funding smart contract.
     *
     */
    function() external payable {
        fund();
    }
}
