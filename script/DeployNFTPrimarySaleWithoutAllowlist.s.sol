// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {NFTPrimarySaleWithoutAllowlist} from "../src/example/NFTPrimarySaleWithoutAllowlist.sol";
import "forge-std/Script.sol";

// Forge script deployment
// forge script script/DeployNFTPrimarySaleWithoutAllowlist.s.sol:NFTPrimarySaleWithoutAllowListScript --rpc-url <RPC_URL> --broadcast --verify <ETHERSCAN_API_KEY> -vvvv

contract NFTPrimarySaleWithoutAllowlistScript is Script {
    uint256 private constant _WAD = 1000000000000000000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory name = "DN404";
        string memory symbol = "DN";
        uint256 maxMint = 10;
        uint120 publicPrice = 0.02 ether;
        uint96 initialSupply = uint96(1000 * _WAD);
        address owner = address(vm.addr(deployerPrivateKey));

        NFTPrimarySaleWithoutAllowlist cntrct = new NFTPrimarySaleWithoutAllowlist(
            name, symbol, maxMint, publicPrice, initialSupply, owner
        );

        // Set token base URI prior to going live
        cntrct.setBaseURI("");

        // Make contract live once deployed
        cntrct.toggleLive();

        vm.stopBroadcast();
    }
}
