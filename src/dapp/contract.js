import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import { FlightStatusQueueMap, StatusMap } from './shared';
export default class Contract {
    constructor(network, callback) {

        this.config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(this.config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, this.config.appAddress);

        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];

        this.web3socket = new Web3(new Web3.providers.WebsocketProvider(this.config.wsUrl));
        const socketInstance = new this.web3socket.eth.Contract(FlightSuretyApp.abi, this.config.appAddress);
        socketInstance.events.allEvents({ fromBlock: 0 }, (err, event) => {
            console.log(err, event)
            if (event?.event === "FlightStatusInfo" && FlightStatusQueueMap?.[event?.returnValues?.flight]) {
                alert("Your Flight Status: " + StatusMap[event?.returnValues?.status]);
                delete FlightStatusQueueMap?.[event?.returnValues?.flight];
            }
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

            callback();
        });


    }

    isOperational(callback) {
        let self = this;
        self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner }, callback);
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
                );
        });
    }

    registerFlight(flightName) {
        return new Promise((resolve, reject) => {
            this.flightSuretyApp.methods
                .registerFlight(flightName)
                .send(
                    {
                        from: this.owner,
                        gas: 5000000
                    },
                    (err, res) => {
                        console.log({ err, res })
                        if (err) reject(err);
                        resolve(res);
                    }
                )
        });
    }

    insureFlightForPassenger(flightKey, value) {
        return new Promise((resolve, reject) => {
            this.flightSuretyApp.methods
                .buyInsurance(flightKey)
                .send(
                    {
                        from: this.owner,
                        gas: 5000000,
                        value: this.web3.utils.toWei(`${value}`, 'ether')
                    },
                    (err, res) => {
                        console.log({ err, res })
                        if (err) reject(err);
                        resolve(res);
                    }
                )
        });
    }

    fetchFlightStatus(flightKey) {
        return new Promise((resolve, reject) => {
            this.flightSuretyApp.methods
                .fetchFlightStatus(flightKey, Math.floor(Date.now() / 1000))
                .send({ from: this.owner, gas: 5000000, }, (err, res) => {
                    console.log({ err, res })
                    if (err) reject(err);
                    resolve(res);
                })
        });
    }

    checkMyBalance() {
        return new Promise((resolve, reject) => {
            this.flightSuretyApp.methods
                .checkMyBalance()
                .call({ from: this.owner, gas: 5000000, }, (err, balance) => {
                    console.log({ err, balance })
                    if (err) reject(err);
                    resolve(this.web3.utils.fromWei(`${balance}`, 'ether'));
                })
        });
    }

    withdrawFromBalance(amount) {
        return new Promise((resolve, reject) => {
            this.flightSuretyApp.methods
                .withdrawFromBalance(this.web3.utils.toWei(`${amount}`, 'ether'))
                .send({ from: this.owner, gas: 5000000, }, (err, res) => {
                    console.log({ err, res })
                    if (err) reject(err);
                    resolve(res);
                })
        });
    }
}