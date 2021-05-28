### Dependency Graph

#### C3_Linearization

- FlightSuretyAirlinesData (inherits) -> FlightSuretyAccessControl
- FlightSuretyFlightsData (inherits) -> FlightSuretyAccessControl
- FlightSuretyOraclesData (inherits) -> FlightSuretyAccessControl
- FlightSuretyPassengersData (inherits) -> FlightSuretyAccessControl
- FlightSuretyData -> FlightSuretyAirlinesData, FlightSuretyFlightsData, FlightSuretyOraclesData, FlightSuretyPassengersData
