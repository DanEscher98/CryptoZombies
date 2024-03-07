// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

using Math for uint256;


contract ZombieFactoryIO {
  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
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

  constructor() Ownable(msg.sender) {}
  
  function _createZombie(string memory _name, uint _dna) internal {
    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    ZombieId id = ZombieId.wrap(zombies.length - 1);

    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender];

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

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= block.timestamp);
  }

  function getZombieById(ZombieId _id) public view returns (Zombie memory) {
    return zombies[ZombieId.unwrap(_id)];
  }
}

contract ZombieFeeding is ZombieFactory {
  KittyInterface public kittyContract;

  constructor(address _ckAddress) {
    kittyContract = KittyInterface(_ckAddress);
  }

  // ch6
  modifier isOwnerOf(ZombieId _id) {
    require(msg.sender == zombieToOwner[_id]);
    _;
  }

  function setKittyContract(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function feedAndMultiply(ZombieId _id, uint _targetDna, string memory _species) internal isOwnerOf(_id) {
    Zombie storage my_zombie = getZombieById(_id);
    
    require(_isReady(my_zombie));

    _targetDna = _targetDna % dnaModulus;
    uint newDna = (my_zombie.dna + _targetDna) / 2;

    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);

    _triggerCooldown(my_zombie);
  }

  function feedOnKitty(ZombieId _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,, kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}

contract ZombieHelper is ZombieFeeding {
  uint levelUpFee = 0.001 ether;

  constructor(address _ckAddress) ZombieFeeding(_ckAddress) {}

  modifier aboveLevel(uint _level, ZombieId _id) {
    require(getZombieById(_id).level >= _level);
    _;
  }

  function changeName(ZombieId _id, string calldata _newName) external aboveLevel(2, _id) isOwnerOf(_id){
    zombies[ZombieId.unwrap(_id)].name = _newName;
  }

  function changeDna(ZombieId _id, uint _newDna) external aboveLevel(20, _id) isOwnerOf(_id) {
    zombies[ZombieId.unwrap(_id)].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns (uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;

    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[ZombieId.wrap(i)] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  // ch1 payable
  function levelUp(ZombieId _id) external payable {
    require(msg.value == levelUpFee);
    zombies[ZombieId.unwrap(_id)].level++;
  }

  // ch2 withdraws
  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
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

// ch3 zombie battles
contract ZombieAttack is ZombieHelper {
  // ch4 random numbers
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  constructor(address _ckAddress) ZombieHelper(_ckAddress) {}
  
  // ch4
  function randMod(uint _modulus) internal returns (uint) {
    randNonce++;
    uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
    return random % _modulus;
  }

  // ch5 zombie fighting
  function attack(ZombieId _id, ZombieId _target) external isOwnerOf(_id) {
    Zombie storage myZombie = getZombieById(_id);
    Zombie storage targetZombie = getZombieById(_target);
    uint rand = randMod(100);

    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      targetZombie.lossCount++;
      feedAndMultiply(_id, targetZombie.dna, "zombie");
    } else {
      myZombie.lossCount--;
      targetZombie.lossCount--;
      _triggerCooldown(myZombie);
    }
  }
}

// TODO: natspec
// @title
// @author
// @dev
abstract contract ZombieOwnership is ZombieAttack, IERC721 {

  mapping(uint => address) zombieApprovals;

  // ch5 transfer logic
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    zombieToOwner[ZombieId.wrap(_tokenId)] = _to;
    ownerZombieCount[_from]--;
    ownerZombieCount[_to]++;

    emit Transfer(_from, _to, _tokenId);
  }

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address owner) {
    return zombieToOwner[ZombieId.wrap(_tokenId)];
  }

  // ch6
  function transferFrom(address _from, address _to, uint256 _tokenId) external {
    // only owner or and approved address for the token, can call transfer
    require (zombieToOwner[ZombieId.wrap(_tokenId)] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  // ch7
  function approve(address _approved, uint256 _tokenId) external isOwnerOf(ZombieId.wrap(_tokenId)) {
    zombieApprovals[_tokenId] = _approved;
    // ch8 Approve
    emit Approval(zombieToOwner[ZombieId.wrap(_tokenId)], _approved, _tokenId);
  }

  // function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {}
  // function safeTransferFrom(address from, address to, uint256 tokenId) external {}
  // function setApprovalForAll(address operator, bool approved) external {}
  // function getApproved(uint256 tokenId) external view returns (address operator) {}
  // function isApprovedForAll(address owner, address operator) external view returns (bool) {}
}
