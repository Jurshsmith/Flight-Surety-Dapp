


import FlightSuretyApp from './../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

const config = Config['localhost'];
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
export const flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);

