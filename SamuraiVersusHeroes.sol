// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";  
import "@openzeppelin/contracts/utils/Pausable.sol";     
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {Error} from "./Constants.sol";


contract SamuraiVersusHeroes is ERC721, Ownable, Pausable, ERC2981 {

    uint256 private currentId;
    string private description;
    string private baseImage;
    string private external_url;

    mapping(uint256 => string) private names;
    mapping(uint256 => string) private images;
    mapping(uint256 => string) private attributes;


    constructor(address initialOwner, string memory _description, string memory _imageUri, uint96 royalty)
        ERC721("Samurai Heroes", "SH")
        Ownable(initialOwner)
    {
        description = _description;
        baseImage = _imageUri;
        setRoyalty(initialOwner, royalty);
    }


    function mint(
        string memory _name,  
        string memory _image,  
        string memory _attribute) 
        external onlyOwner {
            _safeMint(msg.sender, currentId);
            setName(currentId, _name);
            setImage(currentId, _image);
            setAttributes(currentId, _attribute);
            ++currentId;
        }


    // METADATA SETTERS

    function setName(uint256 tokenId, string memory _name) public onlyOwner {
        require(_ownerOf(tokenId) != address(0), Error.NFT_NOT_EXISTS);
        names[tokenId] = _name;
    }

    function setImage(uint256 tokenId, string memory _image) public onlyOwner {
        require(_ownerOf(tokenId) != address(0), Error.NFT_NOT_EXISTS);
        images[tokenId] = _image;
    }

    function setAttributes(uint256 tokenId, string memory _attribute) public onlyOwner {
        require(_ownerOf(tokenId) != address(0), Error.NFT_NOT_EXISTS);
        attributes[tokenId] = _attribute;
    }

    function setDiscription(string memory _description) public onlyOwner {
        description = _description;
    }

    function setIPFSUri(string memory ipfsUri) public onlyOwner {
        baseImage = ipfsUri;
    }

    function setExternalLink(string memory link) external onlyOwner {
        external_url = link;
    }


    // GLOBAL SETTERS

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setRoyalty(address reciver, uint96 fee) public onlyOwner {
        _setDefaultRoyalty(reciver, fee);
    }

    function delRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    // GETTERS

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

            if (_ownerOf(tokenId) != address(0)) {
                bytes memory dataURI = abi.encodePacked(
                    '{',
                    '"name": "', names[tokenId], '",',
                    '"description": "', description, '",',
                    '"image": "', baseImage, images[tokenId], '",',
                    '"external_url": "', external_url, '", ',
                    '"attributes": ', attributes[tokenId],
                    '}'
                );

                return string(
                        abi.encodePacked(
                        "data:application/json;base64,",
                        Base64.encode(dataURI)
                    )
                );
            }
        return "";

    }


    // SERVICE
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override whenNotPaused returns (address) {
        return super._update(to, tokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
