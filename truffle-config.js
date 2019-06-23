const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = process.env.MNEMONIC;

module.exports = {
  networks: {
    "ganache_cli": {
      host: 'localhost',
      port: '8545',
      network_id: '*',
    },
    ganache: {
      host: 'localhost',
      port: '7545',
      network_id: '*',
    },
    rsk: {
      provider: () => new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co:443'),
      network_id: '*',
      gas: 2500000,
      gasPrice: 183000,
    },
  },
  compilers: {
    solc: {
      version: '0.5.0',
      settings: {
        optimizer: {
          enabled: false,
          runs: 200,
        },
        evmVersion: 'byzantium',
      },
    },
  },
};
