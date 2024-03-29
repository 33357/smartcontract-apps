# BRC20 解析

## 备注

时间：2023 年 11 月 29 日

作者：[33357](https://github.com/33357)

## BRC20 的由来

自比特币诞生以来，就有无数人想在BTC网络上发行第三方资产，然而比特币的 UTXO 交易系统扩展性并不好，想要把设计之外的数据加上去非常困难，即使强行加上去也不实用。

Oridinals协议则改变了这一点。它利用 BTC 的隔离见证和 Taproot 实现了在 BTC 网络上低成本的数据上链。BRC20 则在此基础上规定了资产发行的数据格式，实现了在 BTC 网络上批量发行第三方资产。

## ORDI 的诞生

技术做出来了，还要得到市场的认可。unisat 团队在推广 BRC20 上下了很大的功夫，不仅做了交易网站还推出了钱包，也提供 BRC20 资产的API 服务。 BRC20 的龙头资产 ORDI 推出短短几个月就实现了上万倍的价格涨幅，引爆了市场的 fomo 情绪。随着支持 BRC20 的交易所逐渐增多，BRC20 资产流动性差的问题也在逐渐改善。

## BRC20 的发展

BTC 社区对于新功能的开发非常克制，BRC20 热潮导致的 GAS 费高涨也影响了原有的用户。保守者认为这些垃圾数据堵塞了 BTC 网络，威胁了 BTC 系统的可用性和安全性；进步者则认为新功能的开发有利于进一步发展 BTC 生态。

目前而言，更多的人还在观望，毕竟 BRC20 还是个新东西，也不是一个能够去中心化执行的协议，各种 BUG 和攻击会源源不断。但是在 BTC 网络上发行第三方资产的前景依旧很大，因为 BTC 网络上还有很多没接触过第三方资产的受众，还都很有钱。

虽然 BRC20 的发行是去中心化的，但目前 BRC20 的交易都是中心化的，存在价格操纵和虚假交易的问题。而且 BTC 网络的交易速度太慢，金融工具不够健全，资产流动性不如 ERC20。

想投资 BRC20 的要谨慎考虑技术和市场方面的风险。

## BRC20 的技术分析

BRC20 操作代码标准

```
{  
    "p": "brc-20",      // Protocol: 帮助线下的记账系统识别和处理brc-20事件  
    "op": "deploy",     // op 操作: 事件类型 (Deploy, Mint, Transfer)  
    "tick": "ordi",     // Ticker: brc-20代币的标识符，长度为4个字母（可以是emoji） 
    "max": "21000000",  // Max supply: brc-20代币的最大供应量  
    "lim": "1000"       // Mint limit: 每次brc-20代币铸造量的限制}
}
```

操作步骤

- 转账 sat，一般是自己到自己。

- 附加 BRC20 操作代码。

- 签名并发送交易上链

BRC20 只能做到数据存储上链，数据的计算和执行需要依靠中心化的排序器。排序器需要从第 0 个区块开始把所有的 BRC20 操作数据下载并计算，排除所有不合规的操作后得到每个钱包的 BRC20 代币余额。

由于排序器的计算是中心化的，容易出现单点故障，目前看来 BRC20 系统整体的稳定性比不上 ERC20。后续可能需要推出去中心化的排序器才能解决这个问题。

## 其他想法

一些人把 BRC20 做了改变迁移到了 EVM 上，eths 就是其中的代表。但我并不看好在 EVM 上发行 BRC20资产，因为 ERC20 的功能比 BRC20 强大的多，也不依靠中心化排序器保障功能的运行。但 BRC20 相比 ERC20 确实节约了存储和计算成本，也不能算完全没用，因此无法下定论。

相比 BRC20，我其实更看好的是在 BTC 上做 L2。BRC20 在本质上是 L2 概念中证明上链的一种实现。通用性更好、运行速度更快的 BTC L2 能够实现用 BTC 发行资产的同时，给到比 BRC20 更强的功能和更好的用户体验。

## 总结

BRC20 为 BTC 网络上发行第三方资产提供了工具，但是否能形成和 ERC20 一样强大的生态，还要看后续的市场和技术发展。