# 如何预测最低的 GasPrice

如何使用最低的 GasFee 完成交易的执行，对于以太坊上的用户而言是非常重要的事情。虽然以太坊通过 EIP1559 更新了 Gas 的算法，新增了 maxFeePerGas 和 maxPriorityFeePerGas。但据我的研究，使用经过预算的 GasPrice 依旧是目前在确保交易执行的前提下最节省 GasFee 的设定方法。

## 为什么依旧使用 GasPrice

假设下一个区块的 baseFeePerGas 是 15 gwei，交易池中有两笔交易，一笔 gasPrice = 16.5 gwei，另一笔 maxFeePerGas = 17 gwei，maxPriorityFeePerGas = 1 gwei。区块中只能再容下一笔交易，你是矿工你会打包哪一笔交易？对于矿工来说必然会打包自己能收到小费最多的交易，也就是 gasPrice = 16.5 gwei 的那笔交易。而下一个区块因为 gasUsed 高涨必然会提高 baseFeePerGas，另一笔交易只能等待 baseFeePerGas 的下次回落。因此使用 gasPrice 在捕捉低 gasFee 的区块方面更有优势。

## 平均 GasPrice

在计算一个块的 gasPrice时，经常会使用以下算法：gasPrice = gasFee / gasUsed。可以看来这是一个平均值算法，计算出来的就是平均 gasPrice。通常情况下，支付按平均 gasPrice 预测的 gasPrice 可以在交易打包时容易进入交易队列中间。但这对交易队列顺序不敏感的交易毫无意义，如果打包进交易队列的末尾反而是更为有利的，因为可以少支付 gasFee。

## 使用 GasLimit 预测最低 GasPrice

如果想要准确预测交易能否进入交易队列的末尾，就需要提供准确的交易 gasLimit。在计算区块的 gasPrice 时，需要取 0 - gasLimit 这段交易的 gasFee / gasLimit 来得到最低 gasPrice。通过最低 gasPrice 来预测需要发出交易的 gasPrice 就能比通过平均 gasPrice 预测的 gasPrice 更节约 GasFee。

## 如何使用最低 GasPrice

目前我做了自己也在用的一个成品 https://gas.33357.club/ ，只要按以下步骤就能获得当前以太坊网络的最低 GasPrice。

- 链接区块链钱包
- 输入 GasLimit 和 waitTime
- 点击 Estimate

## 最后

这是我的一些经验和想法，希望对大家有用，也欢迎大家讨论。