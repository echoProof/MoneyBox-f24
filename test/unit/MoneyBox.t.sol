//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoneyBox} from "../../src/MoneyBox.sol";
import {DeployMoneyBox} from "../../script/DeployMoneyBox.s.sol";

contract MoneyBoxTest is Test {
    MoneyBox moneyBox;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant SEND_LESS_THEN_GOAL = 3000000000000000;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployMoneyBox deployMoneyBox = new DeployMoneyBox();
        moneyBox = deployMoneyBox.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimusUsdIsFive() public view {
        assertEq(moneyBox.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(moneyBox.getOwner(), msg.sender);
    }

    function testpriceFeedVerssionIsAccurate() public view {
        uint256 version = moneyBox.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        moneyBox.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amoutFunded = moneyBox.getAddressToAmountFunded(USER);
        assertEq(amoutFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunder() public funded {
        address funder = moneyBox.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        moneyBox.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        moneyBox.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = moneyBox.getOwner().balance;
        uint256 startingContractBalance = address(moneyBox).balance;
        vm.prank(moneyBox.getOwner());
        moneyBox.withdraw();

        uint256 endingOwnerBalance = moneyBox.getOwner().balance;
        uint256 endingContractBalance = address(moneyBox).balance;
        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingContractBalance + startingOwnerBalance);
    }

    function testTheGoalIsNotAchieved() public {
        vm.prank(USER);
        moneyBox.fund{value: SEND_LESS_THEN_GOAL}();
        vm.prank(moneyBox.getOwner());
        vm.expectRevert();
        moneyBox.withdraw();
    }

    function testWithdrawFromAMultipleAddresses() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // same as vm.prank + vm.deal
            moneyBox.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = moneyBox.getOwner().balance;
        uint256 startingContractBalance = address(moneyBox).balance;

        vm.startPrank(moneyBox.getOwner());
        moneyBox.withdraw();
        assertEq(address(moneyBox).balance, 0);
        assertEq(startingOwnerBalance + startingContractBalance, moneyBox.getOwner().balance);
        vm.stopPrank();
    }

    // function testWithdrawFromAMultipleAddressesCheaper() public funded {
    //     uint160 numberOfFunders = 10;
    //     uint160 startingFunderIndex = 1;
    //     for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
    //         hoax(address(i), SEND_VALUE); // same as vm.prank + vm.deal
    //         moneyBox.fund{value: SEND_VALUE}();
    //     }

    //     uint256 startingOwnerBalance = moneyBox.getOwner().balance;
    //     uint256 startingContractBalance = address(moneyBox).balance;

    //     vm.startPrank(moneyBox.getOwner());
    //     moneyBox.cheaperWithdraw();
    //     assertEq(address(moneyBox).balance, 0);
    //     assertEq(startingOwnerBalance + startingContractBalance, moneyBox.getOwner().balance);
    //     vm.stopPrank();
    // }
}
