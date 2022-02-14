# EIP1559下的 GAS 费设置解析

EIP1559 对 gas 费的收取机制进行了调整，相比之前的方案，这套新的机制显得更加复杂。为了少交一点 gas 费（特别是对于需要跑交易的同学而言），还是非常值得花功夫研究一下的。

## Max priority fee 和 Max fee

相比于之前的方案，EIP1559 将 gasPrice 进行了拆分，变成了 Max priority fee 和 Max fee。要了解这么做的原因，必须了解 EIP1559 下新的 GAS 费收取机制。

- 在 EIP1559 之前，矿工挖矿不仅会获得挖出新区块奖励，还会获得这个区块内所有的交易手续费。用户为一笔交易所指定的 gasPrice * gasUsed 会全部给矿工，作为额外的奖励。

- 在 EIP1559 之后，以太坊系统指定了一个 Base fee，所有交易都会燃烧掉数量为 Base fee * gasUsed 的 ETH，只有 Max priority fee * gasUsed 才会作为奖励给到矿工。如果用户指定的 Max fee > Base fee + Max priority fee，那么多出来的那部分会返还给用户。如果 Max fee > Base fee 但是 Max fee < Base fee + Max priority fee，矿工也可能会打包交易，从而获取部分的 priority fee 奖励。

因此用户在选择 Max fee 时，实际上要同时考虑 Base fee 和 Max priority fee 这两个费用。

## Base fee

在 EIP1559 之前，区块链上的 gas 费是由矿工，这整个群体来决定的，他们完全可以选择只打包 gasPrice 高昂的交易从而让用户不得不多出 gas 费。而在 EIP1559 之后，区块链上的 gas 费就完全由以太坊系统决定了，而这个由以太坊系统决定价格就是 Base fee。

- 决定以太坊系统上 Base Fee 的因素只有一个，就是上一个区块打包的 gas limit 是否使用超过了一半。如果超过了一半，就提升下一个区块的 Base Fee，最多提升 12.5%；如果没有超过一半，就减少下一个区块的 Base Fee，最多减少 12.5%。

可以看到，在 EIP1559 的规则之下，矿工失去了对 gas 费的定价权：如果他们只打包少量高 gas 的交易导致区块容量不满一半，以太坊系统就会减少 Base fee，降低用户的使用费用。（实际上在 EIP1559 规则之下这么做，对矿工也没有好处）

## EIP1559 下矿工的选择

对于一些跑交易的同学来说，重要的不是 gas 费多少，而是如何跑在对手前面，下面会讲在 EIP1559 规则下面的博弈。

- 对于矿工而言，交易设置多少的 Max fee 其实并不重要，因为矿工并不能因此而得到直接的好处。重要的是，他能从这笔交易里拿到多少：`Min( Max fee - Base fee, Max priority fee)`，下面举个栗子：

    - 已知下一个区块的 Base fee 为 30。在一笔对手的交易中，Max fee 为 32，Max priority fee 为 2，你的交易 Max fee 为 35 ， Max priority fee 为 1，这样的情况下你的交易能优先被矿工打包吗？虽然看起来你的交易支付的 gas 更多，但实际上矿工会优先选择对手的交易。因为矿工能在对手的交易中提取 `Min( 32 - 30, 2) = 2` 的价值，而从你的交易中只能提取 `Min( 35 - 30, 1) = 1` 的价值。

- 另外还有一个比较特殊的情况，目前 EIP1559 下区块的 gas limit 为 3000 万，如果你的交易 gas limit 太多（比如 1000 万）而矿工可以从中提取的价值不够，矿工同样不会为了你而丢弃其他可提取价值高的交易。因此 gas limit 低其本生就是一种优势。

以上就是目前对于 EIP1559 下的 GAS 费设置解析，欢迎补充内容和我讨论。
