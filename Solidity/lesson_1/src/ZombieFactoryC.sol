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
  
  mapping (ZombieId => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;
  

  function _createZombie(string memory _name, uint _dna) internal {
    zombies.push(Zombie(_name, _dna));
    ZombieId id = ZombieId.wrap(zombies.length - 1);

    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender]++;

    emit NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  function createRandomZombie(string memory _name) public {
    require(ownerZombieCount[msg.sender] == 0);

    uint randomDna = _generateRandomDna(_name);
    _createZombie(_name, randomDna);
  }
}

contract ZombieFeeding is ZombieFactory {
  KittyInterface public kittyContract;

  constructor(address _ckAddress) {
    kittyContract = KittyInterface(_ckAddress);
  }

  // ch1 Immutability of Contracts
  function setKittyContract(address _address) external {
    kittyContract = KittyInterface(_address);
  }

  function feedAndMultiply(ZombieId _id, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_id]);
    Zombie storage my_zombie = zombies[ZombieId.unwrap(_id)];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (my_zombie.dna + _targetDna) / 2;

    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
  }

  function feedOnKitty(ZombieId _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,, kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}

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
