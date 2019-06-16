const HeritableWalletFactory = artifacts.require('HeritableWalletFactory');
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('HeritableFactory', (accounts) => {
  let contract;
  const creatorAccount = accounts[0];
  const beneficiaryAccount = accounts[1];
  const periodInDays = 1;

  beforeEach(async () => {
    contract = await HeritableWalletFactory.deployed();
  });

  // afterEach(async () => {
  //   await contract.destroy({ from: creatorAccount });
  // });

  describe('#create', function () {
    it('should create a new instance of HeritableWallet contract', async () => {
      const tx = await contract.create(beneficiaryAccount, periodInDays, { from: creatorAccount});

      truffleAssert.eventEmitted(tx, 'WalletCreated', (event) => {
        return event.walletOwner === creatorAccount && event.walletBeneficiary === beneficiaryAccount;
      });
    });

    it('should create add a new entry to contractsByOwner', async () => {
      const tx = await contract.create(beneficiaryAccount, periodInDays, { from: creatorAccount});
      const contractsByOwner =  await contract.getContractsByOwner({ from: creatorAccount});

      truffleAssert.eventEmitted(tx, 'WalletCreated', (event) => {
        return expect(contractsByOwner).to.include(event.walletAddress);
      });
    });

    it('should create add a new entry to contractsByBeneficiary', async () => {
      const tx = await contract.create(beneficiaryAccount, periodInDays, { from: beneficiaryAccount});
      const contractsByBeneficiary =  await contract.getContractsByBeneficiary({ from: beneficiaryAccount});

      truffleAssert.eventEmitted(tx, 'WalletCreated', (event) => {
        return expect(contractsByBeneficiary).to.include(event.walletAddress);
      });
    });

  });
});
