// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ch2 Ownable Contracts
import "@openzeppelin/access/Ownable.sol";

contract ZombieFactoryIO {
  struct Zombie {
    string name;
    uint dna;
    // ch4 gas optimization storage
    uint32 level;
    uint32 readyTime;
  }

  type ZombieId is uint;
  event NewZombie(ZombieId id, string name, uint dna);
}

contract ZombieFactory is ZombieFactoryIO, Ownable {
  uint dnaDigits = 16;
  uint dnaModulus = 10 ^ dnaDigits;
  uint cooldownTime = 1 days;
  Zombie[] public zombies; 
  
  mapping (ZombieId => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;

  // ch2
  constructor() Ownable(msg.sender) {}
  
  // ch5 time units
  function _createZombie(string memory _name, uint _dna) internal {
    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime)));
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

  // ch6 
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= block.timestamp);
  }
}

contract ZombieFeeding is ZombieFactory {
  KittyInterface public kittyContract;

  constructor(address _ckAddress) {
    kittyContract = KittyInterface(_ckAddress);
  }

  // ch1 Immutability of Contracts
  function setKittyContract(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function feedAndMultiply(ZombieId _id, uint _targetDna, string memory _species) internal {
    require(msg.sender == zombieToOwner[_id]);
    Zombie storage my_zombie = zombies[ZombieId.unwrap(_id)];
    
    // ch7 public functions and security
    require(_isReady(my_zombie));

    _targetDna = _targetDna % dnaModulus;
    uint newDna = (my_zombie.dna + _targetDna) / 2;

    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);

    // ch7
    _triggerCooldown(my_zombie);
  }

  function feedOnKitty(ZombieId _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,, kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}

// ch8 more on function modifiers
contract ZombieHelper is ZombieFeeding {
  constructor(address _ckAddress) ZombieFeeding(_ckAddress) {}

  modifier aboveLevel(uint _level, ZombieId _id) {
    require(zombies[ZombieId.unwrap(_id)].level >= _level);
    _;
  }

  // ch9 modifiers
  function changeName(ZombieId _id, string calldata _newName) external aboveLevel(2, _id) {
    require(msg.sender == zombieToOwner[_id]);
    zombies[ZombieId.unwrap(_id)].name = _newName;
  }

  function changeDna(ZombieId _id, uint _newDna) external aboveLevel(20, _id) {
    require(msg.sender == zombieToOwner[_id]);
    zombies[ZombieId.unwrap(_id)].dna = _newDna;
  }

  // ch10 saving gas with 'view'
  function getZombiesByOwner(address _owner) external view returns (uint[] memory) {
    // ch11 storage strategy
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;

    // ch12 for loops
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[ZombieId.wrap(i)] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
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
