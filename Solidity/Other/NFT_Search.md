# NFT 所有者 tokenID 快速查询

最近做项目有一个需求，要求通过用户地址查到用户拥有的 NFT tokenID。由于我做项目向来不高兴写后端，因此考虑使用合约完成这个功能。

## 实现

使用合约来查询数据，一般来说有两个方案：存储数据时多用 Gas，查询数据时少用 Gas；或者存储数据时少用 Gas，查询数据时多用 Gas。在目前的场景下，由于存储数据在链上，查询数据不在链上，所以选择第二个方案能更加省 Gas。同时经过我的实测，这个方法可以实现单次 10000 个以上 tokenId 的遍历，对于一般的 NFT 来说足够了。

```solidity
    function getOwnedTokenIdList(
        address target, // 目标NFT地址
        address owner, // 所有者
        uint256 start, // 起始 tokenId
        uint256 end // 结束 tokenId
    ) external view returns (uint256[] memory tokenIdList) {
        // 起始 tokenId < 结束 tokenId
        require(start < end, "XenBox: end must over start");
        IERC721 erc721 = IERC721(target);
        tokenIdList = new uint256[](end - start);
        uint256 index;
        // 遍历出所有者拥有的 tokenId
        for (uint256 tokenId = start; tokenId < end; tokenId++) {
            if (erc721.ownerOf(tokenId) == owner) {
                tokenIdList[index] = tokenId;
                index++;
            }
        }
        assembly {
            mstore(tokenIdList, index)
        }
    }
```

这个方法我部署在了 https://etherscan.io/address/0x604995B9377Ac6d9aBbC57b902f6936Df69D01db#readContract ，有兴趣的可以来试试。

## 优势和缺点

优势：支持标准的 ERC721，不需要消耗额外的 Gas，也不需要部署后端程序就能实现快速遍历出所有者的 NFT tokenId 。

缺点：不支持非连续的 tokenId 查询。
