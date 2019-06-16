pragma solidity 0.5.0;

import "./HeritableWallet.sol";

contract HeritableWalletFactory {
    address public creator;
    mapping(address => address[]) contractsByBeneficiary;
    mapping(address => address[]) contractsByOwner;

    event WalletCreated(address walletAddress, address walletOwner, address walletBeneficiary);

    constructor() public {
        creator = msg.sender;
    }

    function getContractsByBeneficiary() public view returns (address[] memory contracts) {
        contracts = contractsByBeneficiary[msg.sender];
    }

    function getContractsByOwner() public view returns (address[] memory contracts) {
        contracts = contractsByOwner[msg.sender];
    }

    function create(address payable beneficiary, uint periodInDays) public returns (address payable wallet) {
        wallet = address(new HeritableWallet(beneficiary, msg.sender, periodInDays));
        contractsByBeneficiary[beneficiary].push(wallet);
        contractsByOwner[msg.sender].push(wallet);
        emit WalletCreated(wallet, msg.sender, beneficiary);
    }
}

