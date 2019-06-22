pragma solidity 0.5.0;

import "./HeritableWallet.sol";

contract HeritableWalletFactory {
    address public creator;
    mapping(address => address[]) contractsByOwner;

    event WalletCreated(address walletAddress, address walletOwner);

    constructor() public {
        creator = msg.sender;
    }

    function getContractsByOwner() public view returns (address[] memory contracts) {
        contracts = contractsByOwner[msg.sender];
    }

    function create(uint periodInDays) public returns (address payable wallet) {
        wallet = address(new HeritableWallet(msg.sender, periodInDays));
        contractsByOwner[msg.sender].push(wallet);
        emit WalletCreated(wallet, msg.sender);
    }
}

