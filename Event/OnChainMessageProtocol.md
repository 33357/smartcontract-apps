# 链上通信协议，到底有什么用？

为了做一个链上聊天室，我做了一个链上通信协议。可以看到的是，通过这个协议，我实现了在区块链上发送消息和对消息的索引并获取。

[合约源码](https://github.com/33357/blockchat-contract/blob/master/contracts/upgradeable/BlockChatUpgradeable.sol)

[应用网址](https://app.blockchat.space/)

## 链上通信的实现

- 通信内容的存储
    - 为了减少存储数据占用的GAS，该协议使用了event来存储具体的通信内容。因为通信内容不需要和合约进行直接的交互，因此使用event存储是没有任何问题的。

    - 为了方便通讯数据的获取，需要使用一个uint48的数组存储blocknumber的索引列表。

- 通信内容的获取
    - 获取通讯内容列表时，需要获取到该通讯内容的blocknumber，然后根据blocknumber获取到event上保存的通讯内容列表。

- 设置数据的存储
    - 设置数据可以保存当前账户的设置信息，同样使用event来存储具体内容，在合约使用hash值存储blocknumber的索引。

- 设置数据的获取
    - 获取设置数据时，需要获取到该设置数据的blocknumber，然后根据blocknumber获取到event上保存的设置数据。

## 链上通信的优势与缺点

- 链上通信的优势
    - 可以对接链上的合约
    - 可以兼容区块链账户体系
    - 去中心化程度强
    - 稳定性高

- 链上通信的缺点
    - 通信费用高
    - 通信延时高
    - 通信内容存储长度受限

## 链上通信的使用前景

很多人认为链上通讯会因为它的缺点无法实用，但我认为这并不是不可能的。想要让链上通信实用，需要在满足以下条件的场景内使用：

1.通信带来的收益高于通信成本。

2.对通信的即时性要求不高，但对通信的稳定性要求高。

3.对通信的去中心化程度要求高。

## 链上通信的使用场景

这里是我的一些设想。

1.在合约交互的同时附带通讯信息（比如转账时可以备注）。

2.发送需要加密的信息（比如发送私钥、助记词）。

3.发送需要验证的公开信息（比如博客、订阅内容）。

## 为什么要做链上通信协议

我认为，web3社交平台的核心优势不仅在于去中心化，还在于用户的资产和身份是一体的：你有什么Token就证明了你是谁。而依赖于web2的社交关系搭建的web3社交平台，是可疑而且狭隘的。
介于本人无力自己搭建一套通信体系，我就只能依赖于现有的区块链网络搭建一个去中心化的通信协议了。

希望能对未来有所帮助。