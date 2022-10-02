# smartcontract-apps

这是一个面向中文社区，分析市面上智能合约应用的架构与实现的仓库。

## 前言

学以致用，有用才会去学。Web3 的大潮滚滚而来，个人要做的就是要爬上时代的浪潮，从而改变自己的命运。我致力于传播区块链技术，也是为了躺赢未来人生。但是一个人的力量是渺小的，我希望能通过分享自己在区块链领域摸爬滚打的经验，吸引一批志同道合的朋友，大家一起分享知识和机会，共同走上幸福人生。

## 通知推送

twitter：[im33357dr](https://twitter.com/im33357dr)

## 特别篇

这是一些具有指导性的文章，可以为你指明前进的方向。

- [如何在区块链领域用技术赚钱](./Special/Earn.md)

- [如何成为资深智能合约工程师](./Special/Dev.md)

- [如何成为躺着赚钱的科学家](./Special/Scientist.md)

## 智能合约事件分析

有了区块链技术的基础，在智能合约上编程，真正做到了“code is law，code is money”。这里会收集一些实时的智能合约事件及其技术和模式的分析。

- [又是用户转移资产权限被盗，如何确保加密资产安全？](./Event/ContractApproveHack.md)

- [RandomDAO事件](./Event/RandomDAO.md)

- [EIP1559下的GAS费设置](./Event/EIP1559_GAS.md)

- [X2Y2: 必须修改的中心化NFT挂单奖励机制](./Event/X2Y2_DecentralizedOrderReward.md)

- [链上通信协议](./Event/OnChainMessageProtocol.md)

- [CheapSwap协议的诞生](./Event/CheapSwap.md)

- [以太坊POS合并带来的赚钱机会](./Event/PosMerge.md)

- [ETHW重放攻击](./Event/Replay.md)

## 智能合约应用

- DEX

        去中心化交易所，又称DEX，是指基于区块链上智能合约实现的代币交易类应用。用户可以在区块链上完成“代币定价-支付代币-获得代币”的完整业务流程，实现无需托管的代币交易。但同时用户也会受到交易深度不够、合约被黑客攻击和链上手续费高昂等问题的困扰。

    - [Uniswap_v2](./Apps/DEX/Uniswap_v2/)

- Loan

        去中心化借贷，是DEFI的一种重要形式，是一种基于区块链上智能合约实现的代币借贷类应用。用户可以在区块链上完成“代币存借-收益计算-获得/支付利息”的完整业务流程，实现无需认证的自动化超抵押借贷。

    - [Compound](./Apps/Loan/Compound/)

## Solidity 使用技巧

SOLIDITY 是目前使用最广泛的 EVM 智能合约语言，通过学习它可以了解智能合约的运行机制，并设计出更加符合业务的 DAPP。

- 100 个 Solidity 使用技巧

        提示：阅读本教程需要一定的 solidity 基础知识。为了帮助智能合约开发者更好地使用 Solidity，我会在讲解代码的同时给出测试用例，帮助开发者在实践中更好地理解 Solidity 的特性。在这里，我会使用 [https://remix.ethereum.org/](https://remix.ethereum.org/) 作为 Solidity 的开发工具给大家演示，Soldity 版本为 0.8.12。

    - [1. 合约重入攻击](./Solidity/Solidity_100/1_Reentrancy_Attack/)

    - [2. 交易回滚攻击](./Solidity/Solidity_100/2_Transaction_Rollback_Attack/)

- 其他技巧

    - [最省GAS链上排序](./Solidity/Other/Save_Gas_Sort.md)

## 行业展望
任何技术发展的根本目的，都是按照人的期望对现实世界进行改造。区块链技术的未来在哪里？这取决于现在的从业者和用户对它有什么期望，以及能对现实世界有什么样的改造。我在这里写一些对于区块链行业未来的展望，希望能够让读者能对这个行业的未来有一些开拓性的构想。

- [2022年中展望](./Outlook/2022_MidYear.md)

## 套利机器人
在区块链上实现盈利的机器人有不少种类，如果策略得当的话可以实现躺赚目标。这里会记录一些机器人的类型和实现。

- [搬砖交易机器人](./Robot/Moving_Exchange_Robot/)

- [三明治交易机器人](./Robot/Sandwich_Exchange_Robot/)

- [抢跑机器人](./Robot/Running_Robot/)

- [MEV 是在为谁工作](./Robot/MEV_Who_are_you_working_for.md)

## 加入社群

如果对此事有更大的兴趣，欢迎加入wx社群
wx号:im33357(备注：sc-apps)

## 维护员

[@33357](https://github.com/33357)



