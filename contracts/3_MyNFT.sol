// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    struct Connection {
        address connectedAddress;
        bool consentRequired;
        bool isExchanged;
    }

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => Connection) private _connections;
    mapping(address => bool) private _isExchanged;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mintNFT(uint256 tokenId, string memory tokenURI) external {
        require(!_exists(tokenId), "Token ID already minted");

        _mint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenURI;
    }

    function updateMetadataURI(uint256 tokenId, string memory newTokenURI) external onlyOwner {
        require(_exists(tokenId), "Token ID does not exist");

        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller is not approved or owner of the token"
        );

        _tokenURIs[tokenId] = newTokenURI;
    }

    function getMetadataURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");

        return _tokenURIs[tokenId];
    }

    function setConsentRequired(uint256 tokenId, bool consentRequired) external {
        require(_exists(tokenId), "Token ID does not exist");
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller is not approved or owner of the token"
        );

        _connections[tokenId].consentRequired = consentRequired;
    }

    function connect(uint256 tokenId, address user) external {
        require(_exists(tokenId), "Token ID does not exist");
        require(!_isExchanged[user], "Already exchanged info NFT with this user");

        if (_connections[tokenId].consentRequired) {
            require(
                _isApprovedOrOwner(msg.sender, tokenId),
                "Caller is not approved or owner of the token"
            );
        }

        _connections[tokenId] = Connection(user, _connections[tokenId].consentRequired, true);
        _isExchanged[msg.sender] = true;
        _isExchanged[user] = true;
    }

    function disconnect(uint256 tokenId, address user) external {
        require(_exists(tokenId), "Token ID does not exist");
        require(_connections[tokenId].isExchanged, "No exchange with this user");
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller is not approved or owner of the token"
        );

        delete _connections[tokenId];
        _isExchanged[msg.sender] = false;
        _isExchanged[user] = false;
    }

    function isConnected(uint256 tokenId, address user) public view returns (bool) {
        require(_exists(tokenId), "Token ID does not exist");

        return _connections[tokenId].connectedAddress == user && _connections[tokenId].isExchanged;
    }
}
