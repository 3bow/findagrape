// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TicketNFT is ERC721, Ownable {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private _redeemed;
    mapping(address => bool) private _isRegistered;

    constructor() ERC721("Ticket NFT", "TNFT") {}

    function redeemTicket(
        string memory displayName,
        string memory tokenURI
    ) external {
        require(!_isRegistered[msg.sender], "Ticket already redeemed");
        require(!_redeemed[_generateTokenId(msg.sender, displayName)], "Ticket already redeemed");

        uint256 tokenId = _generateTokenId(msg.sender, displayName);

        // Mint untransferrable NFT with attendee info
        _safeMint(msg.sender, tokenId);

        // Set initial token URI
        _setTokenURI(tokenId, tokenURI);

        // Mark attendee as registered and ticket as redeemed
        _isRegistered[msg.sender] = true;
        _redeemed[tokenId] = true;
    }

    function updateTicketInfo(uint256 tokenId, string memory newTokenURI) external onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token does not exist");

        // Update token metadata
        _setTokenURI(tokenId, newTokenURI);
    }

    function getCustomTokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "Token does not exist");

        _tokenURIs[tokenId] = uri;
    }

    function _generateTokenId(address user, string memory displayName) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(user, displayName)));
    }
}
