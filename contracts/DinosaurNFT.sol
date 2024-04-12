// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DinosaurNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Strings for uint256;
    uint256 private _nextTokenId;
    IERC20 EGGtoken;
    uint256 feedAmount = 100e18;
    uint256 basePower = 100;
    uint256 upgradeBasePower = 500;
    uint256 minPowerToUpgrade = 300;

    struct Dinosaur {
        string name;
        uint256 powerLevel;
    }

    //Array for Dino name, user will get any name randomly
    string[] public dinosaurNames = [
        "Tyrannosaurus",
        "Velociraptor",
        "Brachiosaurus",
        "Stegosaurus",
        "Triceratops",
        "Allosaurus",
        "Spinosaurus"
    ];

    mapping(uint256 => Dinosaur) public dinosaurs;

    event DinosaurMinted(
        uint256 indexed tokenID,
        string name,
        uint256 powerLevel
    );

    event DinosaurUpgraded(
        uint256 indexed tokenID,
        string name,
        uint256 powerLevel
    );
    event DinosaurFed(
        uint256 indexed tokenID,
        string name,
        uint256 newPowerLevel
    );

    constructor() ERC721("Dinosaur", "DINO") Ownable() {
        EGGtoken = IERC20(0x12D60B58Dcb4959C6dEa24CeD8cE8F885B368aA9);
    }

    //***************************************************
    //Kept it free for minting Dino
    function mintDinosaur() external {
        uint256 randomNumber = _random(_msgSender());
        string memory randomName = dinosaurNames[
            randomNumber % dinosaurNames.length
        ];
        dinosaurs[_nextTokenId] = Dinosaur(randomName, basePower);
        emit DinosaurMinted(_nextTokenId, randomName, basePower);
        _safeMint(_msgSender(), _nextTokenId);
        _nextTokenId++;
    }

    function feedDinosaur(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "You must own dinosaur to feed it"
        );
        require(
            EGGtoken.balanceOf(_msgSender()) >= feedAmount,
            "Insufficient balance to FEED"
        );

        EGGtoken.transferFrom(_msgSender(), address(this), feedAmount);

        dinosaurs[_tokenId].powerLevel += 100;
        emit DinosaurFed(
            _tokenId,
            dinosaurs[_tokenId].name,
            dinosaurs[_tokenId].powerLevel
        );
    }

    function upgradeDinosaur(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "You can only upgrade dinosaurs you own"
        );
        require(
            dinosaurs[_tokenId].powerLevel >= minPowerToUpgrade,
            "You should have threshold power to upgrade"
        );
        _burn(_tokenId);

        uint256 randomNumber = _random(_msgSender());
        string memory randomName = dinosaurNames[
            randomNumber % dinosaurNames.length
        ];
        dinosaurs[_nextTokenId] = Dinosaur(randomName, upgradeBasePower);
        emit DinosaurUpgraded(_nextTokenId, randomName, upgradeBasePower);
        _safeMint(_msgSender(), _nextTokenId);
        _nextTokenId++;
    }

    function safeMint(address to) internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    //used suedo randomness, same can be acheived using chainlink vrf
    function _random(address _user) internal view returns (uint256) {
        uint256 hashNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    tx.origin,
                    tx.gasprice,
                    blockhash(block.number),
                    _user
                )
            )
        );
        return ((hashNumber % 999999));
    }

    //onchain metadata is used
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string memory dino = dinosaurs[tokenId].name;
        uint256 power = dinosaurs[tokenId].powerLevel;
        string memory json = string.concat(
            '{"name": "',
            dino,
            " #",
            Strings.toString(tokenId),
            '",',
            '"description": "Increase Power by feeding EGGS to DINOS",',
            '"image": "https://cryptosaurs.one/wp-content/uploads/2021/07/035-jeffrey.png",',
            '"attributes": [{"trait_type": "Power", "value": "',
            Strings.toString(power),
            '"}]}'
        );
        return string.concat("data:application/json;utf8,", json);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
