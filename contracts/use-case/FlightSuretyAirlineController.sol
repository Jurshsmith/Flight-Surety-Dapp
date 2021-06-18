pragma solidity ^0.4.25;

import "./FlightSuretyBaseAppWithAccessControl.sol";

contract FlightSuretyAirlineController is FlightSuretyBaseAppWithAccessControl {
    // Max Flight before voting starts
    uint8 private constant MAX_AIRLINES_TO_END_REFERRAL = 4;

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
            flightSuretyData.registeredAirlinesLength() <
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
                flightSuretyData.getRegisteredAirlineIsParticipating(
                    msg.sender
                ),
                "You are not authorized to register an airline at this point"
            );
            flightSuretyData.registerAirline(airlineAddress);
        }
    }

    function voteForPregisteredAirline(address airlineAddress)
        external
        requireIsOperational
    {
        // In a real-world contract this requireStatement should be single transaction from the flightSuretyData contract
        require(
            flightSuretyData.getRegisteredAirlineIsRegistered(msg.sender),
            "You are not authorized to vote an airline at this point"
        );
        require(
            flightSuretyData.getRegisteredAirlineIsParticipating(msg.sender),
            "You are not authorized to register an airline at this point"
        );
        require(
            flightSuretyData.getPreRegisteredAirlineIsPreRegistered(
                airlineAddress
            ),
            "Airline has not been pre-registered"
        );
        require(
            !flightSuretyData.getHasRegisteredAirlineVote(
                airlineAddress,
                msg.sender
            ),
            "You cant vote more than once"
        );

        uint256 currentPreRegisteredAirlineVotes =
            flightSuretyData.getPreRegisteredAirlineNoOfVotes(airlineAddress);

        currentPreRegisteredAirlineVotes++;

        flightSuretyData.setRegisteredAirlineVote(
            airlineAddress,
            msg.sender,
            currentPreRegisteredAirlineVotes
        );

        uint256 requiredConsensusVotes =
            flightSuretyData.registeredAirlinesLength().div(2);

        if (currentPreRegisteredAirlineVotes >= requiredConsensusVotes) {
            flightSuretyData.registerAirline(airlineAddress);
        }
    }

    function payAirlineSeedFunding() external payable {
        require(
            flightSuretyData.getRegisteredAirlineIsRegistered(msg.sender),
            "Airline is not registered"
        );

        require((msg.value == 10 ether), "Minimum seed funding is 10 ether");

        flightSuretyDataContractAddress.transfer(msg.value);

        flightSuretyData.updateAirlineSeedFundingAmount(msg.sender, msg.value);
        flightSuretyData.setAirlineParticipationStatus(msg.sender, true);
    }
}
