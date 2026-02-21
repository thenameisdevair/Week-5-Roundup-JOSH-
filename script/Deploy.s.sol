// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Devair} from "../src/Devair.sol";
import {SaveAsset} from "../src/SaveAsset.sol";
import {Todo} from "../src/Todo.sol";
import {SchoolMang} from "../src/SchoolMang.sol";

contract DeployScript is Script {
    Devair public devair;
    SaveAsset public saveAsset;
    Todo public todo;
    SchoolMang public schoolMang;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        devair = new Devair();
        saveAsset = new SaveAsset(address(devair));
        todo = new Todo();
        schoolMang = new SchoolMang(address(devair), 100, 200, 300, 400);

        vm.stopBroadcast();
    }
}
