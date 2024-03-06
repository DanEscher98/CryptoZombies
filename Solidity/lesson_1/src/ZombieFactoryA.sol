// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ZombieFactoryIO {
  // ch5 structs
  struct Zombie {
    string name;
    uint dna;
  }

  // ch13 events
  event NewZombie(uint zombieId, string name, uint dna);
}

// ch2 layout
contract ZombieFactory is ZombieFactoryIO {
  // ch3: basic types
  uint dnaDigits = 16;

  // ch4 basic types
  uint dnaModulus = 10 ^ dnaDigits;

  // ch6 state variables, public identifier, basic collections
  Zombie[] public zombies; 
  
  // ch7 functions
  function _createZombie(string memory _name, uint _dna) private {
    // ch8 init struct, array functions
    zombies.push(Zombie(_name, _dna));

    // ch13 events
    uint id = zombies.length - 1;
    emit NewZombie(id, _name, _dna);
  }

  // ch10 pure/view, return values
  function _generateRandomDna(string memory _str) private view returns (uint) {
    // ch11 typecast, hash, byte encoding
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  // ch12 
  function createRandomZombie(string memory _name) public {
    uint randomDna = _generateRandomDna(_name);
    _createZombie(_name, randomDna);
  }

  function getZombiesLength() public view returns (uint) {
    return zombies.length;
  }

  function getZombieById(uint _id) public view returns (Zombie memory) {
    return zombies[_id];
  }
}
