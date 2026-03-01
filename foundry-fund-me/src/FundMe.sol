// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    //s for storage variables

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    //i forimmutable and capson for constant 
    address private immutable i_owner;
    uint256 public constant MINIMUMUSD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUMUSD,"You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "sender is not the owner");
        //we changed it into custom error for gas optimization.
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callsuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callsuccess, "call failed");
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }


    //when someone does not call fund function and sends eth directly to contract address, then we can use receive and fallback functions to handle such cases.

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
//getterfunctions

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
    function getAddresstoAmountFunded(address funder) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }
}