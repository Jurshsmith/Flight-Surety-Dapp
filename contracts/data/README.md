### Dependency Graph

#### C3_Linearization

- FlightSuretyAirlinesData (inherits) -> FlightSuretyAccessControl
- FlightSuretyFlightsData (inherits) -> FlightSuretyAccessControl
- FlightSuretyOraclesData (inherits) -> FlightSuretyAccessControl
- FlightSuretyPassengersData (inherits) -> FlightSuretyAccessControl
- FlightSuretyData -> FlightSuretyAirlinesData, FlightSuretyFlightsData, FlightSuretyOraclesData, FlightSuretyPassengersData

#### Random Lessons

- The data should be like you are designing a database. It's designed as a persisting layer
- Use enum in place of string or bytes32
- Storage, Memory, stack is the place where the variable is stored, Local/State defines both scope and the place in solidity
