pragma solidity ^0.4.25;

import "./FlightSuretyAccessControl.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

// Lessons
// The data should be like you are designing a database. It's designed as a persisting layer
// use enum in place of string
//Storage, Memory, stack is the place where the variable is stored, Local/State defines both scope and the place in solidity
contract FlightSuretyAirlines is FlightSuretyAccessControl {
    using SafeMath for uint256;

    struct PreRegisteredAirline {
        int256 votes;
    }

    struct RegisteredAirline {
        uint256 amountPaid;
    }

    mapping(address => RegisteredAirline) registeredAirlines;
    int256 registeredAirlinesLength = 0;

    mapping(address => PreRegisteredAirline) preRegisteredAirlines;
    int256 preRegisteredAirlinesLength = 0;

    constructor() public {
        registeredAirlines[msg.sender] = RegisteredAirline(0);
        registeredAirlinesLength++;
    }

    function registerAirline(address airline)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        registeredAirlines[airline] = RegisteredAirline(0);
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
}
