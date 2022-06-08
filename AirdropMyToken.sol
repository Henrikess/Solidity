pragma solidity >=0.7.0;

import "./05-MyXtoken.sol";

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
    


contract Airdrop  {

    // Using Libs

    // Structs

    struct Subscriber{
        bool  alreadyRegistered; 
       
    }

    // Enum
    enum Status { ACTIVE, PAUSED, CANCELLED } // mesmo que uint8


    // Properties
    address payable private owner;
    address public tokenAddress;
    address[] private subscribers;
    Status contractState; 

    mapping(address => Subscriber) public signedAddress; //endereços inscritos


    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Events
    event NewSubscriber(address beneficiary, uint amount);

    // Constructor
    constructor(address token) {
        owner = payable(msg.sender);
        tokenAddress = token;
        contractState = Status.PAUSED;
    }


    // Public Functions

    function subscribe() public returns(bool) {
        
        require(hasSubscribed(msg.sender) == false, "Addresses already registered");
        subscribers.push(msg.sender);

        return true;

    }

    function execute() public isOwner returns(bool) {

        uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
        uint256 amountToTransfer = balance / subscribers.length;
        for (uint i = 0; i < subscribers.length; i++) {
            require(subscribers[i] != address(0));
            require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
        }

        return true;
    }

    function state() public view returns(Status) {
        return contractState;
    }


    // Private Functions
    function hasSubscribed(address subscriber) private returns(bool) {
        
        require(signedAddress[subscriber].alreadyRegistered == false, "Addresses already registered");
        signedAddress[subscriber].alreadyRegistered = true;

        return false;
    }

    // Kill
    function kill() public isOwner {
        contractState = Status.CANCELLED;
        selfdestruct(owner); 
        
    }
    
    
}