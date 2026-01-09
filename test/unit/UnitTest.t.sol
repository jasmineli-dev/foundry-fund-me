// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import { ZkSyncChainChecker } from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import { FoundryZkSyncChecker } from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract FundMeTest is Test {
    FundMe fundme;
    DeployFundMe deployfundme;
    address constant USER = address(0); //USER address is 0x0000000000000000000000000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        console.log("Deployed FundMe at address:", address(fundme));
        console.log("Owner of FundMe is:", fundme.getOwner());
        console.log("deployfundme contract", address(deployfundme));
        console.log("msg.sender", msg.sender);
        console.log("FundMe owner balance:", fundme.getOwner().balance);
    }

    function testFundMe() public view {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testMinimumUSD() public view {
        assertEq(fundme.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testGetVersion() public view {
        uint256 version = fundme.getVersion();
        uint256 expectedVersion = deployfundme.version();
        console.log("FundMe version:", version);
        assertEq(version, expectedVersion);
    }

    function testZeroValueFund() public {
        vm.prank(USER);
        vm.expectRevert();
        console.log("USER address:", USER);
        fundme.fund();
    }

    function testNotOwnerWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testOneEntry() public {
        vm.deal(USER, STARTING_BALANCE);
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        assertEq(fundme.addressToAmountFunded(USER), SEND_VALUE);
    }

    function testMultipleEntry() public {
        //An Ethereum address is exactly 160 bits wide, and address(uint160(x)) is the correct and explicit way to construct an address from a number.
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
            assertEq(fundme.addressToAmountFunded(funder), SEND_VALUE);
        }
        assertEq(address(fundme).balance, numberOfFunders * SEND_VALUE);
    }

    function testOwnerWithdrawSingleEntry() public {
        hoax(USER, STARTING_BALANCE);
        //vm.deal(USER, STARTING_BALANCE);
        //vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        vm.prank(fundme.getOwner());

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();

        fundme.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);

        assertEq(address(fundme).balance, 0);
    }

    function testOwnerWithdrawMultipleEntry() public {
        //Arrange
        uint160 numberOfFunders = 10;

        //Act
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, STARTING_BALANCE);
            //vm.deal(funder, STARTING_BALANCE);
            //vm.prank(funder);
            fundme.fund{value: SEND_VALUE}();
        }

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        //Assert
        assertEq(address(fundme).balance, 0);
    }

    function testPrintStorageData() public view {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundme), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundme.getPriceFeed()));
    }
}
