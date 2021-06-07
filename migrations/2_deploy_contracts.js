const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = async (deployer) => {
    let firstAirline = '0xf17f52151EbEF6C7334FAD080c5704D77216b732';

    await deployer.deploy(FlightSuretyData);

    await deployer.deploy(FlightSuretyApp, FlightSuretyData.address);

    flightSuretyDataContract = await FlightSuretyData.deployed();
    flightSuretyAppContract = await FlightSuretyApp.deployed();

    await flightSuretyDataContract.authorizeAddress(FlightSuretyApp.address);

    await flightSuretyAppContract.initializationActions(firstAirline);

    let config = {
        localhost: {
            url: 'http://localhost:8545',
            dataAddress: FlightSuretyData.address,
            appAddress: FlightSuretyApp.address
        }
    }
    fs.writeFileSync(__dirname + '/../src/dapp/config.json', JSON.stringify(config, null, '\t'), 'utf-8');
    fs.writeFileSync(__dirname + '/../src/server/config.json', JSON.stringify(config, null, '\t'), 'utf-8');


}