// SPDX-License-Identifier: MIT

/*

      .oooo.               oooooo     oooo           oooo                      o8o                       
     d8P'`Y8b               `888.     .8'            `888                      `"'                       
    888    888 oooo    ooo   `888.   .8'    .oooo.    888   .ooooo.  oooo d8b oooo  oooo  oooo   .oooo.o 
    888    888  `88b..8P'     `888. .8'    `P  )88b   888  d88' `88b `888""8P `888  `888  `888  d88(  "8 
    888    888    Y888'        `888.8'      .oP"888   888  888ooo888  888      888   888   888  `"Y88b.  
    `88b  d88'  .o8"'88b        `888'      d8(  888   888  888    .o  888      888   888   888  o.  )88b 
     `Y8bd8P'  o88'   888o       `8'       `Y888""8o o888o `Y8bod8P' d888b    o888o  `V88V"V8P' 8""888P' 

*/

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {BalanceTransferLimitedToken} from "../src/tokens/BalanceTransferLimitedToken.sol";

/// @title BalanceTransferLimitedTokenTest
/// @notice A test suite for the BalanceTransferLimitedToken smart contract
contract BalanceTransferLimitedTokenTest is Test {
    // state variable for the contract we want to test
    BalanceTransferLimitedToken token;

    // state variables for the actors in the test
    address owner = makeAddr("owner");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");
    address actor3 = makeAddr("actor3");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;
    uint256 basePointsBalanceLimit = 1000;
    uint256 basePointsTransferLimit = 500;

    /// @notice Sets up the initial state for each test case
    function setUp() public {
        vm.prank(owner);
        token = new BalanceTransferLimitedToken(
            "MockToken",
            "MTK",
            basePointsBalanceLimit,
            basePointsTransferLimit
            );

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
        deal(address(token), actor3, initialTokenActorBalance, true);
    }

    /// @notice Tests if the BalanceTransferLimitedToken is deployed correctly with the expected values
    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), 4 * initialTokenActorBalance);
        assertEq(token.owner(), owner);
        assertEq(token.basePointsBalanceLimit(), 1000);
        assertEq(token.basePointsTransferLimit(), 500);
    }

    /// @notice Tests the allowedMaxBalance and allowedAmount functions for correct calculations
    function test_AllowedTransferBalanceAmount() public {
        assertEq(token.allowedMaxBalance(), (4 * initialTokenActorBalance * basePointsBalanceLimit) / 10000);
        assertEq(token.allowedAmount(), (4 * initialTokenActorBalance * basePointsTransferLimit) / 10000);

        deal(address(token), actor1, 2 * initialTokenActorBalance, true);
        assertEq(token.allowedMaxBalance(), (5 * initialTokenActorBalance * basePointsBalanceLimit) / 10000);
        assertEq(token.allowedAmount(), (5 * initialTokenActorBalance * basePointsTransferLimit) / 10000);
    }

    /// @notice Tests the addition and removal of addresses to/from the balance and transfer limit whitelists
    function test_AddRemoveToWhitelist() public {
        assertEq(token.isBalanceLimitWhitelisted(owner), true);
        assertEq(token.isBalanceLimitWhitelisted(actor1), false);
        assertEq(token.isBalanceLimitWhitelisted(actor2), false);

        assertEq(token.isTransferLimitWhitelisted(owner), true);
        assertEq(token.isTransferLimitWhitelisted(actor1), false);
        assertEq(token.isTransferLimitWhitelisted(actor2), false);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.balanceLimitWL(actor2, true);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.transferLimitWL(actor2, true);

        vm.prank(owner);
        token.balanceLimitWL(actor1, true);
        assertEq(token.isBalanceLimitWhitelisted(actor1), true);

        vm.prank(owner);
        token.transferLimitWL(actor1, true);
        assertEq(token.isTransferLimitWhitelisted(actor1), true);
    }

    /// @notice Tests the transfer limit enforcement for transfers
    function test_TransferLimit() public {
        vm.prank(actor1);
        vm.expectRevert("TransferLimiter: transfer amount exceeds limit");
        token.transfer(actor2, initialTokenActorBalance / 3);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);

        vm.prank(owner);
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(actor2), 2 * initialTokenActorBalance);
    }

    /// @notice Tests the balance limit enforcement for transfers
    function test_BalanceLimit() public {
        // remove transfer limit
        vm.startPrank(owner);
        token.transferLimitWL(actor1, true);
        token.transferLimitWL(actor2, true);
        vm.stopPrank();

        vm.prank(actor1);
        vm.expectRevert("BalanceLimiter: balance amount exceeds limit");
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);

        vm.prank(owner);
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(actor2), 2 * initialTokenActorBalance);

        vm.prank(owner);
        token.balanceLimitWL(actor2, true);

        vm.prank(actor2);
        token.transfer(actor1, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), 2 * initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);
    }
}
