pragma solidity ^0.4.26;

contract FlightSuretyDataAccessControl {
    address private contractOwner; // Account used to deploy contract
    mapping(address => bool) private authorizedAddresses; // Used to determine who can CRUD the persistance layer of the DApp
    bool private operational = true; // Blocks all state changes throughout the contract if false
    event Logger(uint logData);

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor() public {
        contractOwner = msg.sender;
    }

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
     * @dev Modifier that requires the "operational" boolean variable to be "true"
     *      This is used on all state changing functions to pause the contract in
     *      the event there is an issue that needs to be fixed
     */
    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
     * @dev Get operating status of contract
     *
     * @return A bool that is the current operating status
     */
    function isOperational() public view returns (bool) {
        return operational;
    }

    /**
     * @dev Sets contract operations on/off
     *
     * When operational mode is disabled, all write transactions except for this one will fail
     */
    function setOperatingStatus(bool mode) external requireContractOwner {
        operational = mode;
    }

    function authorizeAddress(address addressToAuthorize)
        external
        requireContractOwner
        requireIsOperational
    {
        authorizedAddresses[addressToAuthorize] = true;
    }

    modifier requireAuthorizedAddress() {
        require(
            authorizedAddresses[msg.sender] || msg.sender == contractOwner,
            "Forbidden: Not Authorized"
        );
        _;
    }
}
