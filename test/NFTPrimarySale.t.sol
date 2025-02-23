// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {NFTPrimarySale} from "../src/example/NFTPrimarySale.sol";
import {Merkle} from "murky/src/Merkle.sol";

contract NFTPrimarySaleTest is SoladyTest {
    uint256 internal constant _WAD = 10 ** 18;

    NFTPrimarySale dn;
    Merkle allowlistMerkle;

    address alice = address(111);
    address bob = address(222);

    bytes32 allowlistRoot;
    bytes32[] allowlistData = new bytes32[](2);

    uint120 publicPrice = 0.02 ether;
    uint120 allowlistPrice = 0.01 ether;

    function setUp() public {
        allowlistMerkle = new Merkle();
        allowlistData[0] = bytes32(keccak256(abi.encodePacked(alice)));
        allowlistRoot = allowlistMerkle.getRoot(allowlistData);

        dn = new NFTPrimarySale(
            "DN404",
            "DN",
            allowlistRoot,
            10,
            publicPrice,
            allowlistPrice,
            uint96(1000 * _WAD),
            address(this)
        );
        dn.toggleLive();
        payable(bob).transfer(10 ether);
        payable(alice).transfer(10 ether);
    }

    function testMint() public {
        vm.startPrank(bob);

        vm.expectRevert(NFTPrimarySale.InvalidPrice.selector);
        dn.mint{value: 1 ether}(1);

        vm.expectRevert(NFTPrimarySale.ExceedsMaxMint.selector);
        dn.mint{value: 11 * publicPrice}(11);

        dn.mint{value: 5 * publicPrice}(5);
        assertEq(dn.totalSupply(), 1005 * _WAD);
        assertEq(dn.balanceOf(bob), 5 * _WAD);

        vm.expectRevert(NFTPrimarySale.InvalidMint.selector);
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
        vm.expectRevert(NFTPrimarySale.TotalSupplyReached.selector);
        dn.mint{value: publicPrice}(1);
    }

    function testAllowlistMint() public {
        vm.prank(bob);

        bytes32[] memory proof = allowlistMerkle.getProof(allowlistData, 0);
        vm.expectRevert(NFTPrimarySale.InvalidProof.selector);
        dn.allowlistMint{value: 5 * allowlistPrice}(5, proof);

        vm.startPrank(alice);

        vm.expectRevert(NFTPrimarySale.InvalidPrice.selector);
        dn.allowlistMint{value: 1 ether}(1, proof);

        vm.expectRevert(NFTPrimarySale.ExceedsMaxMint.selector);
        dn.allowlistMint{value: 11 * allowlistPrice}(11, proof);

        dn.allowlistMint{value: 5 * allowlistPrice}(5, proof);
        assertEq(dn.totalSupply(), 1005 * _WAD);
        assertEq(dn.balanceOf(alice), 5 * _WAD);

        vm.expectRevert(NFTPrimarySale.InvalidMint.selector);
        dn.allowlistMint{value: 6 * allowlistPrice}(6, proof);

        vm.stopPrank();
    }
}
