// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// NFT Contract Template
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper Functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./libraries/Base64.sol";

contract NftGame is ERC721 {

  // Character attributes
  struct CharacterAttributes {
    uint characterIndex;
    string imageURI;
    string name;
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint powerAttackDamage;
  }

  // Generate Unique NFT token Ids - ie. 0,1,2,3 etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Game characters
  CharacterAttributes[] defaultCharacters;
  
  // Map tokenId with NFT holder's character attributes
  mapping(uint256 => CharacterAttributes) public nftHoldersAttributes;

  // Mapping NFT holders address 
  mapping(address => uint256) public nftHolder;

 
  constructor (    
     // Pass data into character array when contract initialized
    string[] memory characterNames,
    string[] memory imageURIs,
    uint[] memory characterHps,
    uint[] memory attackDamages,
    uint[] memory powerAttackDamages
    
    // Below, I name the NFT Token ("NAME","SYMBOL")
  )
    ERC721("KNOCKOUT", "KO") 
  { for(uint i=0; i < characterNames.length; i++) {
      // Assign attributes to each character and save them to contract
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: imageURIs[i],
        hp: characterHps[i],
        maxHp: characterHps[i],
        attackDamage: attackDamages[i],
        powerAttackDamage: powerAttackDamages[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Character created: %s w/%s HP - ATTACK: %s ", c.name, c.hp, c.attackDamage);

    }
    // In Solidity, 0 is a default value and I try to stay away from 
    // default values. Let's start at tokenId = 1
      _tokenIds.increment();
  }

  // Users can mint their own nft
  function mintCharacter(uint _characterIndex) external {
    // Get tokenID
    uint256 newTokenId = _tokenIds.current();

    // Assign token to user wallet address
    _safeMint(msg.sender, newTokenId);

    // Pass in the character attributes to this new token
    nftHoldersAttributes[newTokenId] = CharacterAttributes({
        characterIndex: _characterIndex,
        name: defaultCharacters[_characterIndex].name,
        imageURI: defaultCharacters[_characterIndex].imageURI,
        hp: defaultCharacters[_characterIndex].hp,
        maxHp: defaultCharacters[_characterIndex].maxHp,
        attackDamage: defaultCharacters[_characterIndex].attackDamage,
        powerAttackDamage: defaultCharacters[_characterIndex].powerAttackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newTokenId, _characterIndex);

    // Easy way to see: owner address = new NFT Token Id
    nftHolder[msg.sender] = newTokenId;

    // Increment Token Ids
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHoldersAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttack = Strings.toString(charAttributes.attackDamage);
    string memory strPowerAttackDamage = Strings.toString(charAttributes.powerAttackDamage);

    string memory json = Base64.encode (
      bytes(
        string(
          abi.encodePacked(
            '{"name": "', charAttributes.name, ' -- NFT #: ', Strings.toString(_tokenId), '",',
            '"description":"Mike Tyson Punch Out - Blockchain Style!" ,',
            '"image":',charAttributes.imageURI,',',
            '"attributes":[{"trait_types": "Health Points",''"value":' ,strHp,',''"max_value":' ,strMaxHp,',},{"trait_types": "Attack Damage","value":' ,strAttack,',"max_value":' ,strPowerAttackDamage,',}]'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }
}