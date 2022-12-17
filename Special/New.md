# 如何入门智能合约开发

老是有人问我如何入门智能合约开发，这里我分享一些自己的经验。

## 智能合约开发的基础知识
学习智能合约开发最基础的知识，可以快速辨别你是否适合做智能合约开发。

- solidity

[https://docs.soliditylang.org](https://docs.soliditylang.org) 新人必须要了解 solidity 的类型、语法和逻辑。记得官网查询最新的文档，二手的东西不一定好用。

- ethers

[https://docs.ethers.org](https://docs.ethers.org) 用 ethers 来做合约交互，合格的智能合约开发需要会写与合约交互的SDK，这样可以大大方便前后端对接和以后的合约维护工作。

- openzeppelin

[https://docs.openzeppelin.com/contracts](https://docs.openzeppelin.com/contracts) 除非你非常自信，否则不要去自己造轮子。使用现成的开源代码代码可以大大提高你的合约安全性。智能合约由于不可修改并且和资金密切相关，一旦出现 BUG 后果往往会非常严重。

- hardhat

[https://hardhat.org/hardhat-runner/docs](https://hardhat.org/hardhat-runner/docs) 目前最成熟的智能合约框架，不管是合约的编写、测试还是部署都非常有一套。如果你做有一定规模的合约项目，一定要试试它。

- typescript

如果你用 typescript 而不是 javascript 和别人对接项目，那么对面一定会在心里暗暗感谢你的。这是在方便了别人的同时，也拯救了自己。

## 以太坊虚拟机 EVM

目前市面上的 solidity 开发都要求熟悉 EVM 机制，毕竟 solidity 就是为了在以太坊上的运行智能合约而创造的。

- ethereum

[https://ethereum.org/zh/developers/docs](https://ethereum.org/zh/developers/docs) 以太坊开发者官方文档，可以了解以太坊的 EVM 机制。

## 使用智能合约开发工具
合理使用工具可以大大降低智能合约出问题的概率。

- remix

[https://remix.ethereum.org](https://remix.ethereum.org) 适合轻量级智能合约的开发和测试，是智能合约入门的必备工具。

- tenderly

[https://tenderly.co](https://tenderly.co) 比较完备的合约模拟运行工具，适合智能合约仿真测试。

- alchemy

[https://alchemy.com](https://alchemy.com) 目前免费额度最多的区块链节点，适合做需要和节点大量交互的机器人。

## 实践智能合约开发
更着知名智能合约项目做开发，可以了解市场上主流的开发模式，面试问起来也好应付。

- uniswap

[https://github.com/Uniswap](https://github.com/Uniswap) 目前最知名的去中心化交易所，不管是 v2、v3 都有很大的市场占比。

- aave

[https://github.com/aave](https://github.com/aave) 目前市占率最高的去中心化借贷，开创的闪电贷功能很有意思。

## 跟踪智能合约的最新发展
新技术的发展日新月异，不要让自己落后于行业发展。

- eip

[https://eips.ethereum.org](https://eips.ethereum.org) 跟踪 EIP 的最新进展。

## 与行业内专家保持联系

如果遇到问题有人能帮助你，那么试错的成本会大大降低。这里推荐一些经常分享 solidity 开发经验的推主。

- 0xAA

[https://twitter.com/0xAA_Science](https://twitter.com/0xAA_Science) 屁话比较多，但写的 solidity 入门教程还不错。时常分享一些区块链行业的新闻。

- SlowMist

[https://twitter.com/SlowMist_Team](https://twitter.com/SlowMist_Team) 区块链漏洞权威，会出最新的智能合约漏洞分析。

- Dapp_Learning

[https://twitter.com/Dapp_Learning](https://twitter.com/Dapp_Learning) 会分享一些智能合约应用的实现。

- Vitalik

[https://twitter.com/VitalikButerin](https://twitter.com/VitalikButerin) 以太坊创始人，懂的都懂。

## 在社区中多提问和回答

知名的博主通常非常忙碌，没工夫管你的这些小问题。这时候就需要你自己加入一些区块链社群，互帮互助。

- 登链

[https://learnblockchain.cn](https://learnblockchain.cn) 登链是目前国内最大的区块链学习社群。

- 科学家社区

[https://t.me/scientistDAO](https://t.me/scientistDAO) 一群总想着掏光池子的家伙，经常看可以给自己一个发财的梦想。

## 保持平衡的心态

编程总是伴随着 BUG，如果没有一颗平常心，很容易破罐子破摔。这里推荐一些解压的方法。

- 打游戏

对于码农来说门槛最低，价格最便宜的解压方式，记住非必要不骂人。

- 和人分享

一个人痛苦不如一群人痛苦，把你的问题说出来，让大家一起头痛。

- 锻炼

既然脑子不好使，那就不如去锻炼肌肉，起码努力就能有结果。

- 其他

你懂的