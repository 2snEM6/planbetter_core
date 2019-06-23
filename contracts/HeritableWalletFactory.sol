pragma solidity 0.5.0;

import "./HeritableWallet.sol";

contract HeritableWalletFactory {
    address public creator;
    mapping(address => address) contractByOwner;

    event WalletCreated(address walletAddress, address walletOwner);

    constructor() public {
        creator = msg.sender;
    }

    function getContractByOwner() public view returns (address _contract) {
        _contract = contractByOwner[msg.sender];
    }

    function create(uint periodInDays) public returns (address payable wallet) {
        if (contractByOwner[msg.sender] != address(0)) revert();
        wallet = address(new HeritableWallet(msg.sender, periodInDays));
        contractByOwner[msg.sender] = wallet;
        emit WalletCreated(wallet, msg.sender);
    }
}

