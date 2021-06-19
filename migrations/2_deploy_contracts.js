const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = async (deployer) => {
    let firstAirline = '0x4d4e1aD0f5BB358C76171E697c95Da1d406C1096';

    await deployer.deploy(FlightSuretyData);

    await deployer.deploy(FlightSuretyApp, FlightSuretyData.address);

    flightSuretyDataContract = await FlightSuretyData.deployed();
    flightSuretyAppContract = await FlightSuretyApp.deployed();

    await flightSuretyDataContract.authorizeAddress(FlightSuretyApp.address);

    await flightSuretyAppContract.initializationActions(firstAirline);

    let config = {
        localhost: {
            url: 'http://localhost:8545',
            wsUrl: 'ws://localhost:8545',
            dataAddress: FlightSuretyData.address,
            appAddress: FlightSuretyApp.address
        }
    }
    fs.writeFileSync(__dirname + '/../src/dapp/config.json', JSON.stringify(config, null, '\t'), 'utf-8');
    fs.writeFileSync(__dirname + '/../src/server/config.json', JSON.stringify(config, null, '\t'), 'utf-8');


}