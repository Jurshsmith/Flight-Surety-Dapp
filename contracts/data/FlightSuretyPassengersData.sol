pragma solidity ^0.4.26;

import "./FlightSuretyDataAccessControl.sol";

contract FlightSuretyPassengersData is FlightSuretyDataAccessControl {

    struct Passenger {
        bytes32[] flights; // flightKeys in array data structure since flights per passenger tends to be significantly lesser than actual number of registered flights
        uint256 balance;
        bool isRegistered;
    }

    mapping(address => Passenger) passengers;

    modifier requireIsPassenger(address passengerAddress) {
        require(passengers[passengerAddress].isRegistered);
        _;
    }

    function getIsPassengerAPassenger(address passengerAddress)
        external
        view
        requireAuthorizedAddress
        returns (bool)
    {
        return passengers[passengerAddress].isRegistered;
    }

    /**
     * @dev Register passenger
     *
     */
    function registerPassenger(address passengerAddress)
        external
        payable
        requireIsOperational
        requireAuthorizedAddress
    {
        passengers[passengerAddress] = Passenger(new bytes32[](0), 0, true);
    }

    /**
     * @dev update passenger flight status data
     *
     */
    function updatePassengerFlightInsurance(
        address passengerAddress,
        bytes32 flightKey
    )
        external
        payable
        requireIsOperational
        requireAuthorizedAddress
        requireIsPassenger(passengerAddress)
    {
        passengers[passengerAddress].flights.push(flightKey);
    }

    /**
     *  @dev Get passenger's flights
     */
    function getPassengerFlights(address passengerAddress)
        external
        view
        requireIsOperational
        requireAuthorizedAddress
        requireIsPassenger(passengerAddress)
        returns (bytes32[])
    {
        return passengers[passengerAddress].flights;
    }

    /**
     *  @dev Get passenger's balance
     */
    function getPassengerBalance(address passengerAddress)
        external
        requireIsOperational
        requireAuthorizedAddress
        requireIsPassenger(passengerAddress)
        returns (uint256)
    {
        emit Logger(passengers[passengerAddress].balance);
        return passengers[passengerAddress].balance;
    }

    /**
     * @dev Set passengers balance
     *
     */

    function setPassengerBalance(address passengerAddress, uint256 amount)
        external
        requireIsOperational
        requireAuthorizedAddress
    {
        passengers[passengerAddress].balance = amount;
    }

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fundPassengerWallet(address passengerAddress, uint256 amount)
        public
        payable
        requireIsOperational
        requireAuthorizedAddress
    {
        emit Logger(amount);
        passengers[passengerAddress].balance += amount;
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function payPassenger(address passengerAddress, uint256 amount)
        external
        requireIsOperational
        requireAuthorizedAddress
    {
        uint256 passengerBalance = passengers[passengerAddress].balance;
        require(amount <= passengerBalance, "Insufficient funds");

        passengerAddress.transfer(amount);
    }
}
