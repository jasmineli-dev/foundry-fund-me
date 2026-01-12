// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract InteractionsTest is ZkSyncChainChecker, StdCheats, Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address alice = makeAddr("alice"); //alice = address(uint160(uint256(keccak256("alice"))))

    function setUp() external {
        if (isZkSyncChain() || block.chainid == 300) {
            //block.chainid == 324 || block.chainid == 280 ||block.chainid == 300
            vm.skip(true);
        } else {
            deployFundMe = new DeployFundMe();
            (fundMe, ) = deployFundMe.run();
        }

        vm.deal(alice, STARTING_USER_BALANCE);
        //fundMe.getOwner() == msg.sender here
    }

    function testUserCanFundAndOwnerWithdraw() public skipZkSync {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Using vm.prank to simulate funding from the alice address
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}(); //alice fund 0.1

        //broadcasting and pranks are not compatible
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe)); // not explicitly setting msg.sender

        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(
            preOwnerBalance + fundMeBalanceBefore + SEND_VALUE,
            afterOwnerBalance
        );
    }
}
