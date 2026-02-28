//SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    function setUp() external {
        fundMe = new FundMe();
    }
    function testminimumUSD() public view {
        assertEq(fundMe.MINIMUMUSD(), 5 * 10 ** 18);
    }
    function testownerismsgsender() public view {
        assertEq(fundMe.i_owner(), address(this));
    }
}