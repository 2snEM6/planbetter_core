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
    Heir public mainHeir;
    address payable public owner;
    uint public lastCheckInTime;
    uint public checkInPeriod;

    event HeritageProposal(address heritableWalletAddress, address walletOwner, address walletProposedHeritage);

    struct Heir {
        address payable heritableWalletAddress;
        address payable ownAddress;
        bool accepted;
        bool pending;
    }

    /* constructor */
    constructor(address payable walletOwner, uint periodInDays) public {
        factory = HeritableWalletFactory(msg.sender); // asume the creator is always the factory

        mainHeir = Heir(address(this), address(0), false, false); // First initial intended beneficiary
        //mainBeneficiary = walletBeneficiary;// First initial intended beneficiary
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
        if (mainHeir.ownAddress == msg.sender) revert();
        _; // function body
    }

    function isAcceptedHeritage() private view returns (bool) {
        return mainHeir.accepted;
    }

    /* called by owner periodically to prove he is alive */
    function checkIn() public onlyOwner {}

    function acceptHeritage() public onlyHeir {
        mainHeir.accepted = true;
    }

    function proposeHeritage() public {
        if (msg.sender == owner) revert(); // Cannot propose heritage to itself
        if (mainHeir.pending) // Cannot propose when there is already a pending proposal
        if (!mainHeir.pending && mainHeir.accepted) // Cannot propose when a heir has already been accepted
        if (!mainHeir.pending && !mainHeir.accepted && mainHeir.ownAddress == address(0) && mainHeir.heritableWalletAddress == address(this)) {
            mainHeir = Heir(address(this), msg.sender, false, true);
            emit HeritageProposal(address(this), owner, msg.sender);
        }
    }

    /* called by owner to change check in period */
    function setCheckInPeriod(uint periodInDays) public onlyOwner {
        checkInPeriod = periodInDays * 1 days;
    }

    /* called by owner to reset the heir */
    function resetHeir() public onlyOwner {
        mainHeir = Heir(address(this), address(0), false, false);
    }

    /* called by an heir to collect his share in the inheritance */
    function claimInheritance() public onlyHeir {
        if (now <= lastCheckInTime + checkInPeriod) revert(); // owner was active recently
        if (!isAcceptedHeritage()) revert();

        uint amount = address(this).balance;

        if (!msg.sender.send(amount)) { // transfer proper amount to heir or revert state if it fails
            revert();
        }

        selfdestruct(owner);
    }

    /* called by owner to terminate this contract */
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    function getOwner() public view returns (address) { return owner; }
    function getHeir() public view returns (address) { return mainHeir.ownAddress; }

}
