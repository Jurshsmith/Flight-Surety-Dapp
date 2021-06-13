const Test = require("../config/testConfig.js");
const BigNumber = require("bignumber.js");

contract("Flight Surety Tests", async (accounts) => {
    let config;
    before("setup contract", async () => {
        config = await Test.Config(accounts);
        await config.flightSuretyData.authorizeAddress(
            config.flightSuretyApp.address
        );
    });

    describe("FlightSuretyApp", () => {
        describe("Operations and settings", () => {
            it(`has correct initial isOperational() value`, async function () {
                // Get operating status
                let status = await config.flightSuretyData.isOperational.call();
                assert.equal(status, true, "Incorrect initial operating status value");
            });

            it(`can block access to setOperatingStatus() for non-Contract Owner account`, async function () {
                // Ensure that access is denied for non-Contract Owner account
                let accessDenied = false;
                try {
                    await config.flightSuretyData.setOperatingStatus(false, {
                        from: config.testAddresses[2],
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

            it(`can allow access to setOperatingStatus() for Contract Owner account`, async function () {
                // Ensure that access is allowed for Contract Owner account
                let accessDenied = false;
                try {
                    await config.flightSuretyData.setOperatingStatus(false);
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
                await config.flightSuretyData.setOperatingStatus(false);

                let reverted = false;
                try {
                    await config.flightSuretyApp.authorizeAddress(
                        config.testAddresses[4]
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
                await config.flightSuretyData.setOperatingStatus(true);
            });
        });

        describe("Airline Registration", () => {
            it("(referral) cannot register an Airline using registerAirline() if it is not funded", async () => {
                // ARRANGE
                let newAirline = accounts[2];

                // ACT
                try {
                    await config.flightSuretyApp.registerAirline(newAirline, {
                        from: config.firstAirline,
                    });
                } catch (e) { }
                let result =
                    await config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
                        newAirline
                    );

                // ASSERT
                assert.equal(
                    result,
                    false,
                    "Airline should not be able to register another airline if it hasn't provided funding"
                );
            });

            it("(multiparty) should allow existing airlines register airlines until we have four registered airlines", async () => {
                // enable participation of registered airline 1 by paying 10 eth
                const paymentDue = new BigNumber(10).multipliedBy(config.weiMultiple);

                await config.flightSuretyApp.payAirlineSeedFunding({
                    from: config.firstAirline,
                    value: paymentDue,
                });

                // register airline 2 and check it is registered, repeat cycle till 4th airline
                const testAccounts = accounts.slice(3, 6);


                (await Promise.allSettled(
                    testAccounts
                        .map((newAirline, i) =>
                            [
                                config.flightSuretyApp.registerAirline(newAirline, {
                                    from: testAccounts?.[i - 1] || config.firstAirline,
                                }),
                                config.flightSuretyApp.payAirlineSeedFunding({
                                    from: newAirline,
                                    value: paymentDue,
                                })
                            ]
                        )
                ));

                const newAirlinesRegistered = (await Promise.all(
                    testAccounts.map(newAirline => config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
                        newAirline
                    ))
                )).filter(Boolean)


                assert.equal(
                    newAirlinesRegistered.length,
                    testAccounts.length,
                    "All new Airlines should be able registered since a participating airline referred it"
                );
            });

            it("(multiparty) should register fifth airline using multiparty consensus algorithm", () => {
                // try adding fifth airline and check if it is registration queue (it shouldn't)
                // let 1 airline vote, and check if it is in the registration queue(it shouldn't)
                // let 2 airlines vote, and check if it is in the registration queue(it should)
            });
        });

        describe("Airline participation", () => {
            it("should allow only participating airlines to register a flight", () => {
                // use a non-participating airline
                // try to register a flight with this airline
                // it should fail
            });
        });
    });
});
