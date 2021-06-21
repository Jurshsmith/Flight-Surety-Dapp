pragma solidity ^0.4.26;

import "./FlightSuretyBaseAppWithAccessControl.sol";

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyPassengerController is
    FlightSuretyBaseAppWithAccessControl
{
    using SafeMath for uint256;
     uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
     uint8 private constant PASSENGER_GAINS_DIVISOR = 2;

    struct Passenger {
        mapping(bytes32 => uint256) flights; // flightKey -> amountPaidToInsure
        uint256 balance;
    }

    mapping(address => Passenger) passengers;

    event NewPassenger(
        address passengerAddress,
        uint256 amountInsured,
        bytes32 flightKey
    );

    modifier requireIsPassenger() {
        require(
            flightSuretyData.getIsPassengerAPassenger(msg.sender),
            "You have to have purchased a flight insurance"
        );
        _;
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buyInsurance(bytes32 flightKey)
        external
        payable
        requireIsOperational
    {
        require(msg.value <= 1 ether, "You cannot insure more than 1 ether");
        require(msg.value > 0 ether, "You have to insure some ether");
        flightSuretyDataContractAddress.transfer(msg.value);

        flightSuretyData.registerPassenger(msg.sender);
        flightSuretyData.updatePassengerFlightInsurance(msg.sender, flightKey);
        flightSuretyData.setAmountInsuredByRegisteredInAFlight(
            flightKey,
            msg.sender,
            msg.value
        );

        emit NewPassenger(msg.sender, msg.value, flightKey);
    }

    /**
     * @dev Check balance for passenger
     *
     */
    function checkMyBalance(bytes32 flightKey)
        external
        requireIsOperational
        requireIsPassenger
        returns (uint256)
    {
        // evaluate all the flights of a passenger and evaluate balance
        bytes32[] memory flights = flightSuretyData.getPassengerFlights(
            msg.sender
        );
        // create an isEvaluated flag for Passenger to avoid DDOS
        for (uint256 i = 0; i < flights.length; i++) {
            if (flightSuretyData.getFlightStatusCode(flightKey) == STATUS_CODE_LATE_AIRLINE) {
                // fund passenger wallet 1.5 the amount insure since it was delayed
                uint256 amountToFundPassenger = flightSuretyData
                .getPassengerBalanceFromThisFlight(flightKey, msg.sender);

                flightSuretyData.fundPassengerWallet(
                    msg.sender,
                    amountToFundPassenger + amountToFundPassenger.div(PASSENGER_GAINS_DIVISOR)
                );

                // set flight passenger wallet to zero
                flightSuretyData.setAmountInsuredByRegisteredInAFlight(
                    flightKey,
                    msg.sender,
                    0
                );
            }
        }

        return flightSuretyData.getPassengerBalance(msg.sender);
    }

    function withdrawFromBalance(uint256 amount)
        external
        requireIsOperational
        requireIsPassenger
    {
        uint256 passengerBalance = flightSuretyData.getPassengerBalance(
            msg.sender
        );
        require(
            passengerBalance >= amount,
            "You don't have this amount of funds to withdraw"
        );
        flightSuretyData.setPassengerBalance(
            msg.sender,
            passengerBalance.sub(amount)
        );
        flightSuretyData.payPassenger(msg.sender, amount);
    }
}
