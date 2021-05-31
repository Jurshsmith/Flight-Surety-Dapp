pragma solidity ^0.4.25;

import "./FlightSuretyAccessControl.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyAirlinesData is FlightSuretyAccessControl {
    using SafeMath for uint256;

    struct PreRegisteredAirline {
        uint256 votes;
        bool isPreRegistered;
    }

    struct RegisteredAirline {
        uint256 seedFundingAmount;
        bool isRegistered;
        bool isParticipating;
    }

    mapping(address => RegisteredAirline) registeredAirlines;
    uint256 public registeredAirlinesLength = 0;

    mapping(address => PreRegisteredAirline) preRegisteredAirlines;
    uint256 public preRegisteredAirlinesLength = 0;

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline(address airlineAddress)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        registeredAirlines[airlineAddress] = RegisteredAirline(0, true, false);
        registeredAirlinesLength++;
    }

    function preRegisterAirline(address airlineAddress)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        preRegisteredAirlines[airlineAddress] = PreRegisteredAirline(0, true);
        preRegisteredAirlinesLength++;
    }

    modifier requireAirlineIsRegistered(address airlineAddress) {
        require(
            registeredAirlines[airlineAddress].isRegistered,
            "Airline not registered"
        );
        _;
    }

    modifier requireAirlineIsPreRegistered(address airlineAddress) {
        require(
            preRegisteredAirlines[airlineAddress].isPreRegistered,
            "Airline not pre-registered"
        );
        _;
    }

    function getRegisteredAirlineIsRegistered(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isRegistered;
    }

    function getPreRegisteredAirlineIsPreRegistered(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return preRegisteredAirlines[airlineAddress].isPreRegistered;
    }

    function getAirlineParticipationStatus(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isParticipating;
    }

    function setAirlineParticipationStatus(
        address airlineAddress,
        bool isParticipating
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireAirlineIsRegistered(airlineAddress)
    {
        // You want to avoid hitting your DB(persistence layer) as much as possible
        registeredAirlines[airlineAddress].isParticipating = isParticipating;
    }

    function updateAirlineSeedFundingAmount(
        address airlineAddress,
        uint256 seedFundingAmount
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireAirlineIsRegistered(airlineAddress)
    {
        registeredAirlines[airlineAddress]
            .seedFundingAmount += seedFundingAmount;
    }

    function getPreRegisteredAirlineNoOfVotes(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (uint256)
    {
        return preRegisteredAirlines[airlineAddress].votes;
    }

    function setPreRegisteredAirlineNoOfVotes(
        address airlineAddress,
        uint256 votes
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireAirlineIsPreRegistered(airlineAddress)
    {
        preRegisteredAirlines[airlineAddress].votes = votes;
    }
}
