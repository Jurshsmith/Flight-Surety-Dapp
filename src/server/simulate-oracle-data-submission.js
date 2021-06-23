import { accountsForOracleSimulation } from "./accounts-for-oracle-simulation";

const heap = { hasRegisteredServerOracleAccounts: false, oracles: [], oraclesWithAtLeastOneCurrentEventIndex: [] };


export const processOracleRegistration = async (flightSuretyApp) => {
  try {
    if (!heap?.hasRegisteredServerOracleAccounts) {

      const oracleRegistrationFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call();

      heap.oracles = (await Promise.all(
        accountsForOracleSimulation.map(oracleAccountAddress =>
          (async () => {
            await flightSuretyApp.methods.registerOracle().send({
              from: oracleAccountAddress,
              value: oracleRegistrationFee,
              gas: 5000000
            });

            const indexes = await flightSuretyApp.methods
              .getMyIndexes()
              .call({ from: oracleAccountAddress });

            return { oracleAccountAddress, indexes }
          })()
        )
      ));

      heap.hasRegisteredServerOracleAccounts = true;
    }
  } catch (e) {
    console.log("An error occurred processing oracle registration");
  }
}

export const simulateOracleDataSubmission = async (event, flightSuretyApp) => {
  const STATUS_CODES = [0, 10, 20, 30, 40, 50];

  const {
    index,
    airline,
    flight,
    timestamp,
    oracleKey } = event;



  const _determineOraclesWithRequiredEventIndex = async () => {
    heap.oraclesWithAtLeastOneCurrentEventIndex = heap.oracles.filter(({ indexes }) => indexes.includes(index));
  }

  const _simulateOracleResponses = async () => {
    try {
      await Promise.all(
        heap.oraclesWithAtLeastOneCurrentEventIndex.map(
          oracle =>
            flightSuretyApp
              .methods
              .submitOracleResponse(
                index,
                airline,
                flight,
                timestamp,
                STATUS_CODES[Math.floor(Math.random() * STATUS_CODES.length)],
                oracleKey
              )
              .send({
                from: oracle.oracleAccountAddress,
                gas: 5000000
              })
        )
      );

    } catch (e) {
      console.log("Oracle wasn't accepted")
    };

  }

  await _determineOraclesWithRequiredEventIndex();

  await _simulateOracleResponses();
}