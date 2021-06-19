const Test = require("../../configs/test/test.config.js");

contract("Flight Surety App Tests", async (accounts) => {
  let config;
  let configWrapper = {};

  before("setup contract", async () => {
    config = await Test.Config(accounts);
    configWrapper.config = config;
    await config.flightSuretyData.authorizeAddress(
      config.flightSuretyApp.address
    );
  });

  describe("FlightSuretyApp", () => {
    // Stateful testing
    require('./operationAndSettings.spec')({ describe, it, configWrapper });

    require('./airlineRegistration.spec')({ describe, it, configWrapper, accounts });

    require('./airlineParticipation.spec')({ describe, it, configWrapper, accounts });

  });
});
