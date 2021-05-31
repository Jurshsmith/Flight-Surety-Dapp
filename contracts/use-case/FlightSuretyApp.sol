pragma solidity ^0.4.25;

import "../data/FlightSuretyData.sol";
import "./FlightSuretyAppAccessControl.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyApp is FlightSuretyAppAccessControl {
    using SafeMath for uint256;

    FlightSuretyData flightSuretyData;
    address flightSuretyDataContractAddress;

    // Flight status codes
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    // Max Flight before voting starts
    uint8 private constant MAX_AIRLINES_TO_END_REFERRAL = 4;

    /**
     * @dev Contract constructor
     *
     */
    constructor(address dataContractAddress) public {
        flightSuretyDataContractAddress = dataContractAddress;
        flightSuretyData = FlightSuretyData(dataContractAddress);

        flightSuretyData.registerAirline(msg.sender); // assuming the first person to deploy the contract (Contract owner) wants to be first airline
    }

    function giveAccessToFlightSuretyData(address myAddress)
        external
        requireContractOwner
    {
        flightSuretyData.authorizeAddress(myAddress);
    }

    /**
     * @dev Add an airline to the registration queue
     *
     */
    function registerAirline(address airlineAddress)
        external
        requireIsOperational
        returns (bool)
    {
        bool requiresReferral =
            flightSuretyData.registeredAirlinesLength() <=
                MAX_AIRLINES_TO_END_REFERRAL;

        processAirlineRegistration(airlineAddress, requiresReferral);

        return true;
    }

    function processAirlineRegistration(
        address airlineAddress,
        bool requiresReferral
    ) internal {
        if (!requiresReferral) {
            flightSuretyData.preRegisterAirline(airlineAddress);
        } else {
            require(
                flightSuretyData.getRegisteredAirlineIsRegistered(msg.sender),
                "You are not authorized to register an airline at this point"
            );
            flightSuretyData.registerAirline(airlineAddress);
        }
    }

    function voteForPregisteredAirline(address airlineAddress) external {
        require(
            flightSuretyData.getRegisteredAirlineIsRegistered(msg.sender),
            "You are not authorized to vote an airline at this point"
        );
        require(
            flightSuretyData.getPreRegisteredAirlineIsPreRegistered(
                airlineAddress
            ),
            "Airline has not been pre-registered"
        );

        uint256 currentPreRegisteredAirlineVotes =
            flightSuretyData.getPreRegisteredAirlineNoOfVotes(airlineAddress);

        currentPreRegisteredAirlineVotes++;

        flightSuretyData.setPreRegisteredAirlineNoOfVotes(
            airlineAddress,
            currentPreRegisteredAirlineVotes
        );

        uint256 requiredConsensusVotes =
            flightSuretyData.registeredAirlinesLength().div(2);

        if (currentPreRegisteredAirlineVotes >= requiredConsensusVotes) {
            flightSuretyData.registerAirline(airlineAddress);
        }
    }

    function payAirlineSeedFunding(address airlineAddress) external payable {
        require(
            flightSuretyData.getRegisteredAirlineIsRegistered(airlineAddress),
            "Airline is not registered"
        );

        require(msg.value == 10 ether, "Minimum seed funding is 10 ether");

        flightSuretyDataContractAddress.transfer(msg.value);

        flightSuretyData.updateAirlineSeedFundingAmount(
            airlineAddress,
            msg.value
        );
        flightSuretyData.setAirlineParticipationStatus(airlineAddress, true);
    }

    /**
     * @dev Register a future flight for insuring.
     *
     */
    function registerFlight() external pure {}

    /**
     * @dev Called after oracle has updated flight status
     *
     */
    function processFlightStatus(
        address airline,
        string memory flight,
        uint256 timestamp,
        uint8 statusCode
    ) internal pure {}

    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus(
        address airline,
        string flight,
        uint256 timestamp
    ) external {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key =
            keccak256(abi.encodePacked(index, airline, flight, timestamp));

        // oracleResponses[key] = ResponseInfo({
        //     requester: msg.sender,
        //     isOpen: true
        // });

        emit OracleRequest(index, airline, flight, timestamp);
    }

    // region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(
        address airline,
        string flight,
        uint256 timestamp,
        uint8 status
    );

    event OracleReport(
        address airline,
        string flight,
        uint256 timestamp,
        uint8 status
    );

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(
        uint8 index,
        address airline,
        string flight,
        uint256 timestamp
    );

    // Register an oracle with the contract
    function registerOracle() external payable {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        // oracles[msg.sender] = Oracle({isRegistered: true, indexes: indexes});
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes(address account) internal returns (uint8[3]) {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);

        indexes[1] = indexes[0];
        while (indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while ((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex(address account) internal returns (uint8) {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random =
            uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(block.number - nonce++),
                            account
                        )
                    )
                ) % maxValue
            );

        if (nonce > 250) {
            nonce = 0; // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

    function getMyIndexes() external view // returns (uint8[3])
    {
        // call FlightData to get this data
    }

    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse(
        uint8 index,
        address airline,
        string flight,
        uint256 timestamp,
        uint8 statusCode
    ) external {
        // require(
        //     (oracles[msg.sender].indexes[0] == index) ||
        //         (oracles[msg.sender].indexes[1] == index) ||
        //         (oracles[msg.sender].indexes[2] == index),
        //     "Index does not match oracle request"
        // );

        // bytes32 key =
        //     keccak256(abi.encodePacked(index, airline, flight, timestamp));
        // require(
        //     oracleResponses[key].isOpen,
        //     "Flight or timestamp do not match oracle request"
        // );

        // oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (
            false
            // oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES
        ) {
            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }

    function getFlightKey(
        address airline,
        string flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // endregion
}
