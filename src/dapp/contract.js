import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);

        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];

        // this.web3.eth.subscribe('logs', {}, (err, log) => console.log({ err, log }));
        const web3socket = new Web3(new Web3.providers.WebsocketProvider(config.wsUrl));
        const socketInstance = new web3socket.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        socketInstance.events.allEvents({ fromBlock: 0 }, (err, events) => {
            console.log(err, events)
        });

        this.flightSuretyDataSocketInstance = new web3socket.eth.Contract(FlightSuretyData.abi, config.dataAddress);

        this.flightSuretyDataSocketInstance.events.allEvents({ fromBlock: 0 }, (err, events) => {
            console.log("Flight surety data");
            console.log(err, events)
        });

    }

    initialize(callback) {
        this.web3.eth.getAccounts((error, accts) => {

            this.owner = accts[0];

            let counter = 1;

            while (this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while (this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }

            console.log(this.flightSuretyApp);

            callback();
        });


    }

    isOperational(callback) {
        let self = this;
        self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner }, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        }
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner }, (error, result) => {
                callback(error, payload);
            });
    }

    registerFlight(flightName) {
        return new Promise((resolve, reject) => {
            console.log({ ownerStuff: this.owner })
            this.flightSuretyApp.methods
                .registerFlight(flightName)
                .send(
                    { from: this.owner,
                        gas: 5000000  },
                    (err, res) => {
                        console.log({ err, res })
                        if (err) reject(err);
                        resolve(res);
                    }
                )
        });
    }

    payAirlineSeedFunding() {
        return new Promise((resolve, reject) => {

            this.flightSuretyApp.methods
                .payAirlineSeedFunding()
                .send(
                    { from: this.owner, value: this.web3.utils.toWei('10', 'ether') },
                    (err, res) => {
                        console.log({ err, res })
                        if (err) reject(err);
                        resolve(res);
                    }
                ).on('Logger', (data, dataa) => console.log({ data, dataa }))
        });
    }


}