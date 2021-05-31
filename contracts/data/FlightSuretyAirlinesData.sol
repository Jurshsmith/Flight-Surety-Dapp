pragma solidity ^0.4.25;

import "./FlightSuretyAccessControl.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// Lessons
// The data should be like you are designing a database. It's designed as a persisting layer
// use enum in place of string
//Storage, Memory, stack is the place where the variable is stored, Local/State defines both scope and the place in solidity
contract FlightSuretyAirlinesData is FlightSuretyAccessControl {
    using SafeMath for uint256;

    struct PreRegisteredAirline {
        int256 votes;
    }

    struct RegisteredAirline {
        uint256 amountPaid;
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
    function registerAirline(address airline)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        registeredAirlines[airline] = RegisteredAirline(0, true, false);
        registeredAirlinesLength++;
    }

    function preRegisterAirline(address airline)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        preRegisteredAirlines[airline] = PreRegisteredAirline(0);
        preRegisteredAirlinesLength++;
    }

    function getRegisteredAirlineIsRegistered(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isRegistered;
    }
}
