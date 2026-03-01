//SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.s.sol";



contract FundMeTest is Test {

    FundMe fundMe;
    uint constant SEND_VALUE=0.1 ether;
    uint constant STARTING_BALANCE=10 ether;
    address USER = makeAddr("user");
    uint number = 1;

    function setUp() external {
        number = 2;
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe,) = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    //sender becomes msg.sender so in below functions we can write msg.sender rather tha address(this)


    function testNumberIsOne() public view {
        assertEq(number, 1);
    }

    function testminimumUSD() public view {
        assertEq(fundMe.MINIMUMUSD(), 5e18);
    }

    function testownerismsgsender() public view {
        assertEq(fundMe.getOwner(),msg.sender);
        console.log(address(this));
    }
    
    function testVersionisAccurate() public view {
        assertEq(fundMe.getVersion(),4); 
    }
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }
    // this will revert as the below fundMe.fund fails due to insuffient eth (0) and the test will pass
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint amountfunded =fundMe.getAddresstoAmountFunded(USER);
        assertEq(amountfunded,SEND_VALUE);
    }
    function testAddsFunderToArrayOFFunders() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
          assertEq(USER,fundMe.getFunder(0));
    }
    //function testOnlyOwnerWithdraw() public {
        //vm.prank(USER); //it affects the very next external call only thus vm.expect is ignored
        //vm.expectRevert();//Again, it doesn’t call your contract; it just configures the test runner.
        //fundMe.withdraw();
        modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
        }

        function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint startingOwnerBalance=fundMe.getOwner().balance;
        uint startingFundMeBalance=address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint endingOwnerBalance=fundMe.getOwner().balance;
        uint endingFundMeBalance=address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);
        }

        function testWithDrawWithMultipleFunder() public funded{
        //Arrange
        uint160 numberOfFunders=10;
        uint160 startingFundIndex=1;
        for(uint160 i=startingFundIndex;i<numberOfFunders;i++){
            hoax(address(i),SEND_VALUE); //hoax=deal+prank
            fundMe.fund{value:SEND_VALUE}();
        }
        uint startingOwnerBalance=fundMe.getOwner().balance;
        uint startingFundMeBalance=address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint endingOwnerBalance=fundMe.getOwner().balance;
        uint endingFundMeBalance=address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingOwnerBalance+startingFundMeBalance,endingOwnerBalance);
        }
}