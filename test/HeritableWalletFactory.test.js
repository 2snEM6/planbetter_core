const HeritableWalletFactory = artifacts.require('HeritableWalletFactory');
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('HeritableFactory', (accounts) => {
  let contract;
  const creatorAccount = accounts[0];
  const beneficiary = accounts[1];
  const periodInDays = 1;

  beforeEach(async () => {
    contract = await HeritableWalletFactory.new({from: creatorAccount});
  });

  // afterEach(async () => {
  //   await contract.destroy({ from: creatorAccount });
  // });

  describe('#create', function () {
    it('should create a new instance of HeritableWallet contract', async () => {
      const tx = await contract.create(beneficiary, periodInDays);

      truffleAssert.eventEmitted(tx, 'WalletCreated', (event) => {
        return event.walletOwner === creatorAccount && event.walletBeneficiary === beneficiary;
      });
    });
  });
});
