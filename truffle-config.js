const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat";

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost
      port: 8545,            // Standard Ganache UI port
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: "^0.4.25"
    }
  }
};