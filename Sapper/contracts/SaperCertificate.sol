// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// contract SaperCertificate is ERC721, ERC721URIStorage, Ownable {
contract SaperCertificate is ERC721, Ownable {
    uint256 private _nextTokenId;
    address private _saper;

    constructor()
        ERC721("Saper Certificate", "SCBOOM")
        Ownable(msg.sender)
    {
        _saper = msg.sender;
    }

    function safeMint(address to) external {
        require(msg.sender == _saper, "Only the Saper contract can issue a certificate of mastery in the game!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        // _setTokenURI(tokenId, "https://drive.google.com/file/d/1947IjslzIMTIyr8ifEtCnJinQ5Rgmf5e/view");
    }

    function setSaper(address saper) public onlyOwner {
        _saper = saper;
    }

    // function tokenURI(uint256 tokenId)
    //     public
    //     view
    //     override(ERC721, ERC721URIStorage)
    //     returns (string memory)
    // {
    //     return super.tokenURI(tokenId);
    // }

    // function supportsInterface(bytes4 interfaceId)
    //     public
    //     view
    //     override(ERC721, ERC721URIStorage)
    //     returns (bool)
    // {
    //     return super.supportsInterface(interfaceId);
    // }
}