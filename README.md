# smartcontract-apps

学习不是目的，工作不是终点。

## 前言

大家好，我是 33357，目前是一名智能合约工程师。

我从事这门行业，不是为了什么理想，只是为了改变自己的生活。而从某种意义上说，我的确实现了。如果没有从事智能合约，我可能还在 996、考研、为了大厂面试刷题。我应该没有机会在这里，平静地和大家说着这些话。

还记得 21 年 5 月的时候，学校里考研的，找工作的，留级的，都已经定好了。只有我还什么都没有，急得快哭了。上年秋招的时候虽然面试了好几个互联网大厂，但没一个过的。那时候的我孤注一掷，研究 DAPP，凭此投了好几家区块链公司，居然成功了。

第一份工作其实还算顺利，老板人也不坏，但我并不能安心。外地工作必然要买房，房贷那就是身上的一座山，让我几乎看不到未来的模样。思考再三，我在年底辞职了，因为我知道留不住。

接下来是自己干活。我接过项目，也做项目，但接项目没渠道，自己做的没人气。倒是研究机器人赚了点钱，可以勉强维持生活。自己维持现金流其实蛮难的，如履薄冰，最后机器人也做不下去了，只能接着找工作。

22 年中的行业市场很坏，我投了几十家公司，只有五六个面试，最后一个也没去成。最后我找到了一家初创团队，可以远程工作，才结束了这段时期。老实说，从这个时段开始，我才真正摸到了一些行业的门道。

XEN 对我来说是一个神奇的项目。2 月的时候，我发现了 RND，而 XEN 几乎和 RND 有异曲同工之妙。我之前在智能合约上摸索出来的经验在 XEN 上发挥了巨大的功效，赚到了一笔钱，足够我支持自己安稳度过整个行业的熊市了。

接下来，我要开始一段新的人生进度。回想起来，如果和一年半之前有什么不同的话，那就是我不再会去为了生计而工作了，打工人毕竟是没有前途的。区块链的周期依然存在，如果我能从现在开始为行业做出点事情，那么在未来的牛市上，应该会有更大的回报。

祝大家有所收获。

## 通知推送

twitter：[im33357dr](https://twitter.com/im33357dr)

## 加入社群

tg: [smartcontractapps](https://t.me/smartcontractapps)

discord: [智能合约应用](https://discord.gg/YjsvmyG84H)

wx：im33357(备注sc-apps)

## 特别篇

这是一些具有指导性的文章，可以为你指明前进的方向。

<!-- - [Web3 自由之道](./Special/Web3FreeDao.md) -->

- [如何入门智能合约开发](./Special/New.md)

- [如何在区块链领域用技术赚钱](./Special/Earn.md)

- [如何成为资深智能合约工程师](./Special/Dev.md)

- [如何成为躺着赚钱的科学家](./Special/Scientist.md)

## GAS 排名合约分析

[GasTracker](https://etherscan.io/gastracker) 排名靠前的合约具有较高的研究价值

- [Uniswap Universal Router 之 Permit2 合约分析](./Gas/UniswapUniversalRouter_Permit2.md)

## 会议篇

- [黑客松对开发者有什么用](./Meeting/Hackathon.md)

- [2023年香港 web3 嘉年华](./Meeting/Web3HongKong.md)

## 智能合约事件分析

有了区块链技术的基础，在智能合约上编程，真正做到了“code is law，code is money”。这里会收集一些实时的智能合约事件及其技术和模式的分析。

<!-- - [XEN，又一次的 GAS 换真金](./Event/Xen.md) -->

- [当去中心化遇到攻击: BSC停机事件](./Event/WhenAttackDecentralization.md)

- [又是用户转移资产权限被盗，如何确保加密资产安全？](./Event/ContractApproveHack.md)

- [RandomDAO事件](./Event/RandomDAO.md)

- [EIP1559下的GAS费设置](./Event/EIP1559_GAS.md)

- [X2Y2: 必须修改的中心化NFT挂单奖励机制](./Event/X2Y2_DecentralizedOrderReward.md)

- [链上通信协议](./Event/OnChainMessageProtocol.md)

- [CheapSwap协议的诞生](./Event/CheapSwap.md)

- [以太坊POS合并带来的赚钱机会](./Event/PosMerge.md)

- [ETHW重放攻击](./Event/Replay.md)

<!-- - [0转账攻击](./Event/0TransferAttack.md) -->

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

    - [NFT 所有者 tokenID 快速查询](./Solidity/Other/NFT_Search.md)

    - [Solidity 智能合约开发流程](./Solidity/Other/Solidity_Development_Process.md)

    - [如何预测最低的 GasPrice](./Solidity/Other/Lowest_GasPrice.md)

## 一点思考
如何使用技术改善自己的人生，这是每个从业者要解决的首要问题。

- [2022年中展望](./Outlook/2022_MidYear.md)

<!-- - [33357的目标](./Outlook/Target.md) -->

<!-- - [人生的边际效应](./Outlook/Marginal_Utility.md) -->

<!-- - [2022年末总结](./Outlook/2022_End.md) -->

## 以太坊生态研究

- [以太坊扩容：L2 详解](./Search/L2.md)

## 套利机器人
在区块链上实现盈利的机器人有不少种类，如果策略得当的话可以实现躺赚目标。这里会记录一些机器人的类型和实现。

- [搬砖交易机器人](./Robot/Moving_Exchange_Robot/)

- [三明治交易机器人](./Robot/Sandwich_Exchange_Robot/)

- [抢跑机器人](./Robot/Running_Robot/)

- [MEV 是在为谁工作](./Robot/MEV_Who_are_you_working_for.md)

## 维护员

[@33357](https://github.com/33357)



