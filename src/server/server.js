import FlightSuretyApp from './../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';

const config = Config['localhost'];
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
const flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);

const flights = [];

flightSuretyApp.events.OracleRequest({
    fromBlock: 0
  }, (error, event) => {
    if (error) console.log(error)
    console.log(event)
});

flightSuretyApp.events.NewFlight({
  fromBlock: 0
}, (error, newFlight) => {
  if (error) console.log(error);
  console.log({ error, newFlight });
  flights.push({flightKey: newFlight?.returnValues?.flightKey, flightName: newFlight?.returnValues?.flightName})
});

const app = express();
//CORS middleware
const allowCrossDomain = function(_, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type');

  next();
}

app.use(allowCrossDomain);


app.get('/api', (_, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
});

app.get('/api/flights', (_, res) => res.status(200).json({ flights }));

export default app;


