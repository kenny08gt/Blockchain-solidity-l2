//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PriceConverter.sol";

contract FundMe {
//780780
//678939
    using PriceConverter for uint256;

    address public immutable i_owner;

    uint256 public constant minimunUsd = 50 *1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Sender is not owner!");
        _;
    }

    function fund() public payable {
        // how do we send eth to this contract?
        // require(msg.value > 1e18); //1e18 == 1*10**18 == 1000000000000000000
        require(msg.value.getConversionRate() >= minimunUsd, "Didn't send enough!"); 

        // what is reverting?
        // undo any action before, and send remaining gas back
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset array
        funders = new address[](0);

        //actually withdraw

        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }
}