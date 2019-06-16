pragma solidity ^0.5.0;

import "HeritableWallet.sol";

contract HeritableWalletFactory {
    address public creator;
    mapping(address => address[]) public contracts;

    event WalletCreated(address walletAddress, address walletOwner, address walletBeneficiary);

    constructor() public {
        creator = msg.sender;
    }

    function create(address payable beneficiary, uint periodInDays) public returns (address payable wallet) {
        wallet = address(new HeritableWallet(beneficiary, msg.sender, periodInDays));
        contracts[beneficiary].push(wallet);
        emit WalletCreated(wallet, msg.sender, beneficiary);
    }
}

