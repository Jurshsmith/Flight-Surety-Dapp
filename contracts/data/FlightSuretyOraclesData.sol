pragma solidity ^0.4.26;

import "./FlightSuretyDataAccessControl.sol";

contract FlightSuretyOraclesData is FlightSuretyDataAccessControl {
    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester; // Account that requested status
        bool isOpen; // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses; // Mapping key is the status code reported
        // This lets us group responses and identify
        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Register an oracle with the contract
    function registerOracle(address oracleAddress, uint8[3] indexes)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        oracles[oracleAddress] = Oracle({isRegistered: true, indexes: indexes});
    }

    modifier requireRegisteredOracle(address oracleAddress) {
        require(
            oracles[oracleAddress].isRegistered,
            "Not registered as an oracle"
        );
        _;
    }

    function getOracleIndexes(address oracleAddress)
        external
        view
        requireRegisteredOracle(oracleAddress)
        returns (uint8[3])
    {
        return oracles[oracleAddress].indexes;
    }

    function createOpeningForOracleResponse(
        bytes32 oracleResponseKey,
        address oracleAddress
    )
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        oracleResponses[oracleResponseKey] = ResponseInfo({
            requester: oracleAddress,
            isOpen: true
        });
    }

    function addOracleResponse(
        address oracleAddress,
        uint8 index,
        address airline,
        string flight,
        uint256 timestamp,
        uint8 statusCode
    )
        external
        requireAuthorizedAddress
        requireIsOperational
        requireRegisteredOracle(oracleAddress)
    {
        bytes32 key = keccak256(
            abi.encodePacked(index, airline, flight, timestamp)
        );
        require(
            oracleResponses[key].isOpen,
            "Flight or timestamp do not match oracle request"
        );
        oracleResponses[key].responses[statusCode].push(oracleAddress);
    }

    function getOracleNumberOfResponses(bytes32 key, uint8 statusCode)
        external
        view
    {
        oracleResponses[key].responses[statusCode].length;
    }

    function getIfOracleResponseIsOpen(bytes32 oracleKey)
        external
        view
        returns (bool)
    {
        return oracleResponses[oracleKey].isOpen;
    }

    function setOracleResponseIsOpen(bytes32 oracleKey, bool isOpen)
        external
        requireIsOperational
        requireAuthorizedAddress
    {
        oracleResponses[oracleKey].isOpen = isOpen;
    }

    function updateOracleResponsesStatusCode(
        bytes32 oracleKey,
        uint8 statusCode,
        address oracleAddress
    ) external requireIsOperational requireAuthorizedAddress {
        oracleResponses[oracleKey].responses[statusCode].push(oracleAddress);
    }

    function getTotalNumberOfResponsesForThisStatusCode(
        bytes32 oracleKey,
        uint8 statusCode
    ) external view requireAuthorizedAddress returns (uint256) {
        return oracleResponses[oracleKey].responses[statusCode].length;
    }
}
