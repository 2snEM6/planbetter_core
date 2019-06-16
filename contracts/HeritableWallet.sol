pragma solidity 0.5.0;

import "./HeritableWalletFactory.sol";

contract HeritableWallet {
    HeritableWalletFactory public factory;
    address payable public beneficiary;
    address payable public owner;
    mapping(address => uint8) public points;
    mapping(address => address payable) public wallets;
    uint public lastCheckInTime;
    uint public checkInPeriod;
    uint public totalPoints = 0;

    /* constructor */
    constructor(address payable walletBeneficiary, address payable walletOwner, uint periodInDays) public {
        factory = HeritableWalletFactory(msg.sender); // asume the creator is always the factory
        beneficiary = walletBeneficiary; // intended beneficiary
        owner = walletOwner; // who currently controls the wallet
        checkInPeriod = periodInDays * 1 days;
        lastCheckInTime = now;
    }

    /* anyone can deposit funds by sending funds to the contract address */
    function() external payable {}

    modifier onlyOwner() {
        if (msg.sender != owner && msg.sender != HeritableWallet(owner).getOwner()) revert();
        lastCheckInTime = now;
        _; // function body
    }

    modifier onlyHeir() {
        if (points[msg.sender] == 0) revert();
        _; // function body
    }

    /* called by owner periodically to prove he is alive */
    function checkIn() public onlyOwner {}

    /* called by owner to change check in period */
    function setCheckInPeriod(uint periodInDays) public onlyOwner {
        checkInPeriod = periodInDays * 1 days;
    }

    /* called by owner to send funds with data to chosen destination */
    function sendFunds(address payable destination, uint amount) public onlyOwner {
        destination.transfer(amount);
    }

    /* called by owner to change ownership */
    function transferOwnership(address payable newOwner) public onlyOwner {
        owner = newOwner;
        beneficiary = owner;
    }

    /* called by owner to add/modify an heir; inheritance shares are directly proportional to the points assigned */
    function setHeir(address payable heir, uint8 inheritancePoints, uint periodInDays) public onlyOwner returns (address payable) {
        if (wallets[heir] == address(0) && inheritancePoints > 0) {
            wallets[heir] = factory.create(heir, periodInDays);
        } else if (wallets[heir] != address(0) && inheritancePoints == 0) {
            HeritableWallet(wallets[heir]).destroy();
            delete wallets[heir];
        }
        totalPoints -= points[wallets[heir]];
        points[wallets[heir]] = inheritancePoints;
        totalPoints += inheritancePoints;
        return wallets[heir];
    }

    /* called by anyone to give the beneficiary full ownership of this account when his predecessor is inactive */
    function unlock() public {
        if (beneficiary == owner) revert(); // already unlocked
        HeritableWallet(owner).claimInheritance();
        owner = beneficiary;
        lastCheckInTime = now;
    }

    /* called by an heir to collect his share in the inheritance */
    function claimInheritance() public onlyHeir {
        if (beneficiary != owner) revert(); // account is locked
        if (now <= lastCheckInTime + checkInPeriod) revert(); // owner was active recently
        uint8 heirPoints = points[msg.sender];
        uint amount = address(this).balance * heirPoints / totalPoints; // compute amount for current heir
        totalPoints -= heirPoints;
        delete points[msg.sender];
        if (!msg.sender.send(amount)) { // transfer proper amount to heir or revert state if it fails
            totalPoints += heirPoints;
            points[msg.sender] = heirPoints;
            revert();
        }
        if (totalPoints == 0) { // last heir, destroy empty contract
            selfdestruct(owner);
        }
    }

    /* called by owner to terminate this contract */
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    function getOwner() public view returns (address) { return owner; }
    function getBeneficiary() public view returns (address) { return beneficiary; }

}
