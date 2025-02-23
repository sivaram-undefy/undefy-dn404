// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {NFTPrimarySaleWithoutAllowlist} from "../src/example/NFTPrimarySaleWithoutAllowlist.sol";

contract NFTPrimarySaleWithoutAllowlistTest is SoladyTest {
    uint256 internal constant _WAD = 10 ** 18;

    NFTPrimarySaleWithoutAllowlist dn;

    address alice = address(111);
    address bob = address(222);

    uint120 publicPrice = 0.02 ether;

    function setUp() public {
        dn = new NFTPrimarySaleWithoutAllowlist(
            "DN404", "DN", 10, publicPrice, uint96(1000 * _WAD), address(this)
        );
        dn.toggleLive();
        payable(bob).transfer(10 ether);
        payable(alice).transfer(10 ether);
    }

    function testMint() public {
        vm.startPrank(bob);

        vm.expectRevert(NFTPrimarySaleWithoutAllowlist.InvalidPrice.selector);
        dn.mint{value: 1 ether}(1);

        vm.expectRevert(NFTPrimarySaleWithoutAllowlist.ExceedsMaxMint.selector);
        dn.mint{value: 11 * publicPrice}(11);

        dn.mint{value: 5 * publicPrice}(5);
        assertEq(dn.totalSupply(), 1005 * _WAD);
        assertEq(dn.balanceOf(bob), 5 * _WAD);

        vm.expectRevert(NFTPrimarySaleWithoutAllowlist.InvalidMint.selector);
        dn.mint{value: 6 * publicPrice}(6);

        vm.stopPrank();
    }

    function testTotalSupplyReached() public {
        // Mint out whole supply
        for (uint160 i; i < 5000; ++i) {
            address a = address(i + 1000);
            payable(a).transfer(1 ether);
            vm.prank(a);
            dn.mint{value: publicPrice}(1);
        }

        vm.prank(alice);
        vm.expectRevert(NFTPrimarySaleWithoutAllowlist.TotalSupplyReached.selector);
        dn.mint{value: publicPrice}(1);
    }
}
