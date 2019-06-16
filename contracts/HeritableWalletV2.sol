pragma solidity 0.5.0;

import "./HeritableWalletFactory.sol";

/**
An improved version of HeritableWallet.sol.
It implements beneficiary acceptance constraint
this allows the beneficiary to have a record of the contract
in a form of a transaction to call acceptHeritage() function
and also possibly can solve legal requirements where both parties
need to accept the transfer of the funds.
*/
contract HeritableWallet {
    HeritableWalletFactory public factory;
    address payable public mainBeneficiary;
    address payable public owner;
    mapping(address => Heir) public heirs;

    uint public lastCheckInTime;
    uint public checkInPeriod;
    uint public totalPoints = 0;

    struct Heir {
        address heritableWalletAddress;
        bool accepted;
        uint8 points;
    }

    /* constructor */
    constructor(address payable walletBeneficiary, address payable walletOwner, uint periodInDays) public {
        factory = HeritableWalletFactory(msg.sender); // asume the creator is always the factory

        heirs[walletBeneficiary] = Heir(address(this), false, 0); // First initial intended beneficiary
        mainBeneficiary = walletBeneficiary;// First initial intended beneficiary
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
        if (heirs[msg.sender].heritableWalletAddress == address(0)) revert;
        _; // function body
    }

    function isAcceptedHeritage(address heir) private view returns (bool) {
        return heirs[heir].accepted;
    }

    /* called by owner periodically to prove he is alive */
    function checkIn() public onlyOwner {}

    function acceptHeritage() public onlyHeir {
        heirs[msg.sender].accepted = true;
    }

    /* called by owner to change check in period */
    function setCheckInPeriod(uint periodInDays) public onlyOwner {
        checkInPeriod = periodInDays * 1 days;
    }

    /* called by owner to change ownership */
    function transferOwnership(address payable newOwner) public onlyOwner {
        owner = newOwner;
        mainBeneficiary = owner;
    }


    /* called by owner to add/modify an heir; inheritance shares are directly proportional to the points assigned */
    function setHeir(address payable heir, uint8 inheritancePoints, uint periodInDays) public onlyOwner returns (address payable) {
        if (heirs[heir].heritableWalletAddress == address(0) && inheritancePoints > 0) {
            heirs[heir] = Heir(factory.create(heir, periodInDays), false, inheritancePoints);
        } else if (heirs[heir].heritableWalletAddress != address(0) && inheritancePoints == 0) {
            HeritableWallet(heirs[heir].heritableWalletAddress).destroy();
            delete heirs[heir];
        }

        totalPoints -= heirs[heir].points;
            heirs[heir].points = inheritancePoints;
        totalPoints += inheritancePoints;
        return heirs[heir].heritableWalletAddress;
    }

    /* called by anyone to give the beneficiary full ownership of this account when his predecessor is inactive */
    function unlock() public {
        if (mainBeneficiary == owner) revert(); // already unlocked
        if (!this.isAcceptedHeritage(mainBeneficiary)) revert();
        HeritableWallet(owner).claimInheritance();
        owner = mainBeneficiary;
        lastCheckInTime = now;
    }

    /* called by an heir to collect his share in the inheritance */
    function claimInheritance() public onlyHeir {
        if (mainBeneficiary != owner) revert(); // account is locked
        if (now <= lastCheckInTime + checkInPeriod) revert(); // owner was active recently
        if (!this.isAcceptedHeritage(msg.sender)) revert();

        uint8 heirPoints = heirs[msg.sender].points;
        uint amount = address(this).balance * heirPoints / totalPoints; // compute amount for current heir
        totalPoints -= heirPoints;
        heirs[msg.sender].points = 0;

        if (!msg.sender.send(amount)) { // transfer proper amount to heir or revert state if it fails
            totalPoints += heirPoints;
            heirs[msg.sender].points = heirPoints;
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
    function getBeneficiary() public view returns (address) { return mainBeneficiary; }

}
