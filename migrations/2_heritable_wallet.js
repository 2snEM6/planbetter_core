// eslint-disable-next-line no-undef
const HeritableWalletFactory = artifacts.require('./HeritableWalletFactory.sol');

module.exports = (deployer) => {
  deployer.deploy(HeritableWalletFactory);
};
