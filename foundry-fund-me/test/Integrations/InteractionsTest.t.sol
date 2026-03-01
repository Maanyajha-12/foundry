//SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant GASPRICE = 0;
    uint STARTING_VALUE=1 ether;
     // fundMe =new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    function setUp() external {
         DeployFundMe deploy=new DeployFundMe();
         (fundMe,) = deploy.run();
    }
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe=new FundFundMe();
        vm.deal(address(fundFundMe),STARTING_VALUE);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe=new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance==0);
    }
}