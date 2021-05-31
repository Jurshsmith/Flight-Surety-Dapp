pragma solidity ^0.4.25;

import "./FlightSuretyDataAccessControl.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyPassengersData is FlightSuretyDataAccessControl {
    using SafeMath for uint256;

    struct Passenger {
        mapping(bytes32 => uint256) flights; // flightKey -> amountPaidToInsure
        uint256 balance;
    }

    mapping(address => Passenger) passengers;

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy(address passengerAddress, bytes32 flightKey)
        external
        payable
        requireIsOperational
        requireAuthorizedAddress
    {
        passengers[passengerAddress] = Passenger(0);
        passengers[passengerAddress].flights[flightKey] = msg.value;
    }

    /**
     *  @dev Credits payouts to insurees
     */
    function creditInsurees(address passengerAddress, uint256 amount)
        external
        requireIsOperational
        requireAuthorizedAddress
    {
        // check the airline has up to required balance
        // require(passengers[passengerAddress].balance) =
        passengers[passengerAddress].balance = amount;
    }

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fundPassengerWallet(address passengerAddress)
        public
        payable
        requireIsOperational
        requireAuthorizedAddress
    {
        passengers[passengerAddress].balance = msg.value;
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay(address passengerAddress, uint256 amount)
        external
        requireIsOperational
        requireAuthorizedAddress
    {
        uint256 passengerBalance = passengers[passengerAddress].balance;
        require(passengerBalance >= amount, "Insufficient funds");
        passengers[passengerAddress].balance = passengerBalance.sub(amount);

        passengerAddress.transfer(amount);
    }
}
