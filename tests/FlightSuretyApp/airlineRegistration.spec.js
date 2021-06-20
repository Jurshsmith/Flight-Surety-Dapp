
const BigNumber = require("bignumber.js");
const truffleAssert = require('truffle-assertions');

module.exports = ({ configWrapper, accounts }) => describe("Airline Registration", function () {
  it("(referral) cannot register an Airline using registerAirline() if it is not funded", async () => {
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    await configWrapper.config.flightSuretyApp.registerAirline(newAirline, {
      from: configWrapper.config.firstAirline,
    }).catch(e => null);


    // ASSERT
    assert.equal(
      await configWrapper.config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
        newAirline
      ),
      false,
      "Airline should not be able to register another airline if it hasn't provided funding"
    );
  });

  it("(multiparty) should allow existing airlines register airlines until we have four registered airlines", async () => {
    // enable participation of registered airline 1 by paying 10 eth
    const paymentDue = new BigNumber(10).multipliedBy(configWrapper.config.weiMultiple);

    await configWrapper.config.flightSuretyApp.payAirlineSeedFunding({
      from: configWrapper.config.firstAirline,
      value: paymentDue,
    });

    // register airline 2 and check it is registered, repeat cycle till 4th airline
    this.testAccounts = accounts.slice(3, 6);


    (await Promise.allSettled(
      this.testAccounts
        .map((newAirline, i) =>
          [
            configWrapper.config.flightSuretyApp.registerAirline(newAirline, {
              from: this.testAccounts?.[i - 1] || configWrapper.config.firstAirline,
            }),
            configWrapper.config.flightSuretyApp.payAirlineSeedFunding({
              from: newAirline,
              value: paymentDue,
            })
          ]
        )
    ));


    const newAirlinesRegistered = (await Promise.all(
      this.testAccounts.map(newAirline => configWrapper.config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
        newAirline
      ))
    )).filter(Boolean)


    assert.equal(
      newAirlinesRegistered.length,
      this.testAccounts.length,
      "All new Airlines should be able registered since a participating airline referred it"
    );


  });

  it('(referral) should pre-register the fifth airline', async () => {
    this.fifthAirline = accounts[8];
    await configWrapper.config.flightSuretyApp.registerAirline(this.fifthAirline, {
      from: configWrapper.config.firstAirline,
    });

    assert.equal(
      await configWrapper.config.flightSuretyData.getPreRegisteredAirlineIsPreRegistered.call(
        this.fifthAirline
      ),
      true,
      "Fifth Airline should be pre-registered at this point"
    );

  });
  it('(referral) should await consensus before registering', async () => {

    await configWrapper.config.flightSuretyApp.registerAirline(this.fifthAirline, {
      from: configWrapper.config.firstAirline,
    }).catch(() => null);


    // ASSERT
    assert.equal(
      await configWrapper.config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
        this.fifthAirline
      ),
      false,
      "Fifth Airline shouldn't register because it needs consensus"
    );
  })

  it("(multiparty) should register fifth airline using multiparty consensus algorithm", async () => {
    // let 1 airline vote, and check if it is in the registration queue(it shouldn't)
    // let 2 airlines vote, and check if it is in the registration queue(it should)
    await configWrapper.config.flightSuretyApp.voteForPregisteredAirline(this.fifthAirline, { from: configWrapper.config.firstAirline });

    assert.equal(
      await configWrapper.config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
        this.fifthAirline
      ),
      false,
      "Fifth Airline shouldn't register because it still needs consensus"
    );

    await configWrapper.config.flightSuretyApp.voteForPregisteredAirline(this.fifthAirline, { from: this.testAccounts[0] });

    assert.equal(
      await configWrapper.config.flightSuretyData.getRegisteredAirlineIsRegistered.call(
        this.fifthAirline
      ),
      true,
      "Fifth Airline should register after 2 of 4 (50%) votes"
    );

  });
});