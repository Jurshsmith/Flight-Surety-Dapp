const Test = require("../../config/testConfig.js");
const BigNumber = require("bignumber.js");
const truffleAssert = require('truffle-assertions');

contract("Flight Surety Tests", async (accounts) => {
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

    require('./airlineRegistration.spec')({ describe, it, configWrapper, accounts })

    // describe("Airline participation", () => {
    //     it("should allow only participating airlines to register a flight", () => {
    //         // use a non-participating airline
    //         // try to register a flight with this airline
    //         // it should fail
    //     });
    // });
  });
});
