
module.exports = ({ configWrapper }) => {
  describe("Operations and settings tests", () => {
    it(`has correct initial isOperational() value`, async function () {
      // Get operating status
      let status = await configWrapper.config.flightSuretyData.isOperational.call();
      assert.equal(status, true, "Incorrect initial operating status value");
    });

    it(`can block access to setOperatingStatus() for non-Contract Owner account`, async function () {
      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try {
        await configWrapper.config.flightSuretyData.setOperatingStatus(false, {
          from: configWrapper.config.testAddresses[2],
        });
      } catch (e) {
        accessDenied = true;
      }
      assert.equal(
        accessDenied,
        true,
        "Access not restricted to Contract Owner"
      );
    });

    it(`can allow access to setOperatingStatus() for Contract Owner account`, async () => {
      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try {
        await configWrapper.config.flightSuretyData.setOperatingStatus(false);
      } catch (e) {
        accessDenied = true;
      }
      assert.equal(
        accessDenied,
        false,
        "Access not restricted to Contract Owner"
      );
    });

    it(`can block access to functions using requireIsOperational when operating status is false`, async function () {
      await configWrapper.config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try {
        await configWrapper.config.flightSuretyApp.authorizeAddress(
          configWrapper.config.testAddresses[4]
        );
      } catch (e) {
        reverted = true;
      }
      assert.equal(
        reverted,
        true,
        "Access not blocked for requireIsOperational"
      );

      // Set it back for other tests to work
      await configWrapper.config.flightSuretyData.setOperatingStatus(true);
    });
  });
}
