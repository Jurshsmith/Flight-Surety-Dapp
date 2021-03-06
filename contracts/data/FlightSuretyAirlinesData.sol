pragma solidity ^0.4.26;

import "./FlightSuretyDataAccessControl.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyAirlinesData is FlightSuretyDataAccessControl {
    using SafeMath for uint256;

    struct PreRegisteredAirline {
        uint256 voteCount;
        bool isPreRegistered;
        mapping(address => bool) registeredAirlines;
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

    /**
     * @dev Add an airline to the pre-registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function preRegisterAirline(address airlineAddress)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        preRegisteredAirlines[airlineAddress] = PreRegisteredAirline(0, true);
        preRegisteredAirlinesLength++;
    }

    /**
     * @dev get if airline is registered
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getRegisteredAirlineIsRegistered(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isRegistered;
    }

     /**
     * @dev get if airline is participating
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getRegisteredAirlineIsParticipating(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isParticipating;
    }

     /**
     * @dev get if airline is pre-registered
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getPreRegisteredAirlineIsPreRegistered(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return preRegisteredAirlines[airlineAddress].isPreRegistered;
    }

     /**
     * @dev get if airline participation status
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getAirlineParticipationStatus(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return registeredAirlines[airlineAddress].isParticipating;
    }

     /**
     * @dev set if airline participation status
     *      Can only be called from FlightSuretyApp contract
     *
     */
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

     /**
     * @dev get pre-registered airline no of votes
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getPreRegisteredAirlineNoOfVotes(address airlineAddress)
        external
        view
        requireAuthorizedAddress
        returns (uint256)
    {
        return preRegisteredAirlines[airlineAddress].voteCount;
    }

     /**
     * @dev set pre-registered airline no of votes
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function setPreRegisteredAirlineNoOfVotes(
        address airlineAddress,
        uint256 votes
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireAirlineIsPreRegistered(airlineAddress)
    {
        preRegisteredAirlines[airlineAddress].voteCount = votes;
    }


     /**
     * @dev set registered airline vote
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function setRegisteredAirlineVote(
        address preRegisteredAirlineAddress,
        address registeredAirlineAddress,
        uint256 votes
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireAirlineIsPreRegistered(preRegisteredAirlineAddress)
        requireAirlineIsRegistered(registeredAirlineAddress)
    {
        preRegisteredAirlines[preRegisteredAirlineAddress].registeredAirlines[
            registeredAirlineAddress
        ] = true;
        preRegisteredAirlines[preRegisteredAirlineAddress].voteCount = votes;
    }

     /**
     * @dev get if airline has registered airline vote
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function getHasRegisteredAirlineVote(
        address preRegisteredAirlineAddress,
        address registeredAirlineAddress
    )
        external
        view
        requireAuthorizedAddress
        requireAirlineIsPreRegistered(preRegisteredAirlineAddress)
        requireAirlineIsRegistered(registeredAirlineAddress)
        returns (bool)
    {
        return
            preRegisteredAirlines[preRegisteredAirlineAddress]
                .registeredAirlines[registeredAirlineAddress];
    }
}
