
import express from 'express';
import { simulateOracleDataSubmission, processOracleRegistration } from './simulate-oracle-data-submission';
import { flightSuretyApp } from './flightSuretyAppContract.server';

const flights = [];

flightSuretyApp.events.OracleRequest({
  fromBlock: 0
}, (error, event) => {
  if (error)
    console.log(error)
  else {
    const { returnValues: { index, airline, flight, timestamp, oracleKey } } = event;
    simulateOracleDataSubmission({ index, airline, flight, timestamp, oracleKey }, flightSuretyApp);
  }
});

flightSuretyApp.events.NewFlight({
  fromBlock: 0
}, (error, newFlight) => {
  if (error)
    console.log(error);
  else
    flights.push(
      {
        flightKey: newFlight?.returnValues?.flightKey,
        flightName: newFlight?.returnValues?.flightName
      }
    );
});

(async () => {
  await processOracleRegistration(flightSuretyApp);
})();

const app = express();

//CORS middleware
const allowCrossDomain = function (_, res, next) {
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


