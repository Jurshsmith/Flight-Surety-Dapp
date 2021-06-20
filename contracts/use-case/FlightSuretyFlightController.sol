pragma solidity ^0.4.26;

import "./FlightSuretyBaseAppWithAccessControl.sol";

contract FlightSuretyFlightController is FlightSuretyBaseAppWithAccessControl {
    // constants
    // Flight status codes
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    // Fee to be paid when registering oracle
    uint256 public constant ORACLE_REGISTRATION_FEE = 1 ether;
    // Number of oracles that must respond for valid status
    uint256 private constant MIN_ORACLE_RESPONSES = 3;

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(
        address airline,
        bytes32 flight,
        uint256 timestamp,
        uint8 status
    );

    event OracleReport(
        address airline,
        bytes32 flight,
        uint256 timestamp,
        uint8 status
    );

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(
        uint8 index,
        address airline,
        bytes32 flight,
        uint256 timestamp,
        bytes32 oracleKey
    );

    /**
     * @dev Unique random key to register each flight. Serves as a flight id
     *
     */
    function getFlightKey(
        address airline,
        bytes32 flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
     * @dev Register a future flight for insuring.
     *
     */
    function registerFlight(bytes32 flightName) external {
        require(
            flightSuretyData.getAirlineParticipationStatus(msg.sender),
            "Only Pariticipating Airlines can register a flight"
        );
        bytes32 flightKey = getFlightKey(msg.sender, flightName, now);

        emit Logger(flightKey);

        flightSuretyData.registerFlight(
            msg.sender,
            flightName,
            STATUS_CODE_UNKNOWN,
            now,
            flightKey
        );

        emit FlightStatusInfo(msg.sender, flightKey, now, STATUS_CODE_UNKNOWN);
    }

    /**
     * @dev Called after oracle has updated flight status
     *
     */
    function processFlightStatus(
        address airlineAddress,
        bytes32 flightKey,
        uint256 timestamp,
        uint8 statusCode
    ) internal {
        // update flight statusCode
        flightSuretyData.setFlightStatus(flightKey, statusCode);

        emit FlightStatusInfo(airlineAddress, flightKey, timestamp, statusCode);
    }

    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus(
        address airline,
        bytes32 flightKey,
        uint256 timestamp
    ) external {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 oracleResponseKey = keccak256(
            abi.encodePacked(index, airline, flightKey, timestamp)
        );

        // add the key of the oracleResponse - for oracles to update that data
        flightSuretyData.createOpeningForOracleResponse(
            oracleResponseKey,
            msg.sender
        );

        emit OracleRequest(
            index,
            airline,
            flightKey,
            timestamp,
            oracleResponseKey
        );
    }

    // Register an oracle with the contract
    function registerOracle() external payable {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        flightSuretyData.registerOracle(msg.sender, indexes);
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
        uint8 random = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(blockhash(block.number - nonce++), account)
                )
            ) % maxValue
        );

        if (nonce > 250) {
            nonce = 0; // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

    function getMyIndexes() external view returns (uint8[3]) {
        // call FlightData to get this data
        return flightSuretyData.getOracleIndexes(msg.sender);
    }

    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse(
        uint8 index,
        address airline,
        bytes32 flightKey,
        uint256 timestamp,
        uint8 statusCode,
        bytes32 oracleKey
    ) external {
        uint8[3] memory oracleIndexes = flightSuretyData.getOracleIndexes(
            msg.sender
        );

        require(
            (oracleIndexes[0] == index) ||
                (oracleIndexes[1] == index) ||
                (oracleIndexes[2] == index),
            "Index does not match oracle request"
        );

        require(
            flightSuretyData.getIfOracleResponseIsOpen(oracleKey),
            "Flight or timestamp do not match oracle request"
        );

        flightSuretyData.updateOracleResponsesStatusCode(
            oracleKey,
            statusCode,
            msg.sender
        );

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flightKey, timestamp, statusCode);
        if (
            flightSuretyData.getTotalNumberOfResponsesForThisStatusCode(
                oracleKey,
                statusCode
            ) >= MIN_RESPONSES
        ) {
            emit FlightStatusInfo(airline, flightKey, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flightKey, timestamp, statusCode);
        }
    }
}
