// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {ZombieFactory, ZombieFactoryIO} from "../src/ZombieFactoryA.sol";

contract CounterTest is Test, ZombieFactoryIO {
  ZombieFactory public zombie_factory;

  function setUp() public {
    zombie_factory = new ZombieFactory();
  }

  function testFuzz_addedZombie(string memory _name) public {
    zombie_factory.createRandomZombie(_name);
    assertEq(zombie_factory.getZombiesLength(), 1);

    Zombie memory new_zombie = zombie_factory.getZombieById(0);
    assertEq(new_zombie.name, _name);
  }
}
