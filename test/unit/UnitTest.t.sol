// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";

contract FundMeTest is ZkSyncChainChecker, CodeConstants, StdCheats, Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;
    DeployFundMe deployer;

    address constant USER = address(0); //USER address is 0x0000000000000000000000000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        if (isZkSyncChain() || block.chainid == 300) {
            //block.chainid == 324 || block.chainid == 280 ||block.chainid == 300
            vm.skip(true);
        } else {
            deployer = new DeployFundMe();
            (fundMe, helperConfig) = deployer.run();
        }
        vm.deal(USER, STARTING_BALANCE);

        // console.log("chainid:", block.chainid);
        // console.log("Deployed FundMe at address:", address(fundMe));
        // console.log("Owner of FundMe is:", fundMe.getOwner());
        // console.log("deployFundMe contract", address(deployer));
        // console.log("msg.sender", msg.sender);
        // console.log("FundMe owner balance:", fundMe.getOwner().balance);
    }

    function testFundMe() public skipZkSync {
        if (block.chainid == 31337) {
            assertEq(fundMe.getOwner(), msg.sender);
        }
    }

    function testMinimumUSD() public skipZkSync {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18); //Public getter function MINIMUM_USD()
    }

    function testGetVersion() public skipZkSync {
        uint256 version = fundMe.getVersion();
        uint256 expectedVersion = helperConfig
            .getConfigByChainId(block.chainid)
            .version;
        console.log("FundMe version:", version);
        assertEq(version, expectedVersion);
    }

    function testZeroValueFund() public skipZkSync {
        vm.prank(USER);
        vm.expectRevert();
        console.log("USER address:", USER);
        fundMe.fund();
    }

    function testNotOwnerWithdraw() public skipZkSync {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier funded() {
        vm.deal(USER, STARTING_BALANCE);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOneEntry() public funded skipZkSync {
        assertEq(fundMe.addressToAmountFunded(USER), SEND_VALUE);
    }

    function testMultipleEntry() public skipZkSync {
        uint256 fundmeStartBalance = address(fundMe).balance;
        console.log("address(fundMe).balance:", address(fundMe).balance);
        //An Ethereum address is exactly 160 bits wide, and address(uint160(x)) is the correct and explicit way to construct an address from a number.
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
            assertEq(fundMe.addressToAmountFunded(funder), SEND_VALUE);
        }
        uint256 fundmeEndBalance = address(fundMe).balance;
        assertEq(
            fundmeEndBalance - fundmeStartBalance,
            numberOfFunders * SEND_VALUE
        );
    }

    function testOwnerWithdrawSingleEntry() public funded skipZkSync {
        //Arrange
        vm.prank(fundMe.getOwner());
        vm.txGasPrice(GAS_PRICE); //set gas price
        uint256 gasStart = gasleft(); //get gas start

        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);

        assertEq(address(fundMe).balance, 0);
    }

    function testOwnerWithdrawMultipleEntry() public skipZkSync {
        //Arrange
        uint160 numberOfFunders = 10;

        //Act
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, STARTING_BALANCE);
            //vm.deal(funder, STARTING_BALANCE);
            //vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        assertEq(address(fundMe).balance, 0);
    }

    function testPrintStorageData() public skipZkSync {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }
}
