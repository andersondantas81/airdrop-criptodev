pragma solidity >=0.7.0;

import "./03-token.sol";
 import "hardhat/console.sol";

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Airdrop  {

    // Using Libs

    // Structs

    // Enum
    enum Status { ACTIVE, PAUSED, CANCELLED } // mesmo que uint8


    // Properties
    address private owner;
    address public tokenAddress;
    address[] public subscribers;
    Status contractState; 

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Events
    event NewSubscriber(address beneficiary, uint amount);

    mapping(address => bool) claimed;

    // Constructor
    constructor(address token) {
        owner = msg.sender;
        tokenAddress = token;
        contractState = Status.ACTIVE;
    }


    // Public Functions

    function subscribe() public returns(bool) {
        require(contractState == Status.ACTIVE, "Contrato esta pausado!");
        require(hasSubscribed(msg.sender), "address already registered!");
        claimed[msg.sender] = true;
        subscribers.push(msg.sender);
        console.log(subscribers.length);
        return true;

    }

    function execute() public isOwner returns(bool) {

        uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
        console.log(subscribers.length);
        uint256 amountToTransfer = balance / subscribers.length;
        for (uint i = 0; i < subscribers.length; i++) {
            require(subscribers[i] != address(0));
            require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
            
            emit NewSubscriber(subscribers[i], amountToTransfer);
        }

        return true;
    }

    function state() public view returns(Status) {
        return contractState;
    }

    function setState(uint8 status) public isOwner {
        if(status == 1){
            contractState = Status.ACTIVE;
        }
        if(status == 2){
            contractState = Status.PAUSED;
        }
        if(status == 3){
            contractState = Status.CANCELLED;
        }
        
    }

    // Private Functions
    function hasSubscribed(address subscriber) private view returns(bool) {
        if(claimed[subscriber] == true) return false;
        return true;
    }

    // Kill
    function kill(address payable _to) public isOwner {
         selfdestruct(_to);
    }
    
    
}