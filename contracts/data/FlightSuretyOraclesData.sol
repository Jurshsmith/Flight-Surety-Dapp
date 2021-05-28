pragma solidity ^0.4.25;

import "./FlightSuretyAccessControl.sol";

contract FlightSuretyOraclesData is FlightSuretyAccessControl {
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
    function registerOracle(uint8[3] indexes)
        external
        requireAuthorizedAddress
        requireIsOperational
    {
        oracles[msg.sender] = Oracle({isRegistered: true, indexes: indexes});
    }

    function requireRegisteredOracle(address oracleAddress) public view {
        require(
            oracles[oracleAddress].isRegistered,
            "Not registered as an oracle"
        );
    }

    function requireOracleWithPreferredIndex(uint8 index) public view {
        require(
            (oracles[msg.sender].indexes[0] == index) ||
                (oracles[msg.sender].indexes[1] == index) ||
                (oracles[msg.sender].indexes[2] == index),
            "Index does not match oracle request"
        );
    }

    function getOracleIndexes() external view returns (uint8[3]) {
        requireRegisteredOracle(msg.sender);
        return oracles[msg.sender].indexes;
    }

    function addOracleResponse(
        address oracleAddress,
        uint8 index,
        address airline,
        string flight,
        uint256 timestamp,
        uint8 statusCode
    ) external requireAuthorizedAddress requireIsOperational {
        requireRegisteredOracle(oracleAddress);
        requireOracleWithPreferredIndex(index);
        bytes32 key =
            keccak256(abi.encodePacked(index, airline, flight, timestamp));
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
}
