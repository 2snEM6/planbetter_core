const HDWalletProvider = require('truffle-hdwallet-provider');
require('dotenv').config();


module.exports = {
  networks: {
    ganache_cli: {
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
      provider: () => new HDWalletProvider(process.env.MNEMONIC, 'https://public-node.testnet.rsk.co:443'),
      network_id: '*',
      gas: 2500000,
      gasPrice: 183000,
    },
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://rinkeby.infura.io/v3/${process.env.RINKEBY_INFURA_API_KEY}`),
      network_id: 4,
      gas: 3000000,
      gasPrice: 10000000000,
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
