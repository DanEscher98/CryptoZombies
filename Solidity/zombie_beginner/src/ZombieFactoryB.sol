// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ZombieFactoryIO {
  struct Zombie {
    string name;
    uint dna;
  }

  type ZombieId is uint;
  event NewZombie(ZombieId id, string name, uint dna);
}

contract ZombieFactory is ZombieFactoryIO {
  uint dnaDigits = 16;
  uint dnaModulus = 10 ^ dnaDigits;
  Zombie[] public zombies; 
  
  // ch2 mapping, address
  mapping (ZombieId => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;
  

  // ch9 internal specifier
  function _createZombie(string memory _name, uint _dna) internal {
    zombies.push(Zombie(_name, _dna));
    ZombieId id = ZombieId.wrap(zombies.length - 1);

    // ch3 msg.sender, special global variables
    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender]++;

    emit NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  function createRandomZombie(string memory _name) public {
    // ch4 require
    require(ownerZombieCount[msg.sender] == 0);

    uint randomDna = _generateRandomDna(_name);
    _createZombie(_name, randomDna);
  }
}

// ch5 inheritance
contract ZombieFeeding is ZombieFactory {
  KittyInterface public kittieContract;

  // ch11 using an interface
  constructor(address _ckAddress) {
    kittieContract = KittyInterface(_ckAddress);
  }

  // ch7 storage vs memory
  function feedAndMultiply(ZombieId _id, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_id]);
    Zombie storage my_zombie = zombies[ZombieId.unwrap(_id)];
    
    // ch8 calling inherited functions
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (my_zombie.dna + _targetDna) / 2;

    // ch13 bonus kitty genes
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
  }

  // ch12 handling return values
  function feedOnKitty(ZombieId _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,, kittyDna) = kittieContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}

// ch 10 defining an interface
abstract contract KittyInterface {
  function getKitty(uint256 _id) external virtual view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}
