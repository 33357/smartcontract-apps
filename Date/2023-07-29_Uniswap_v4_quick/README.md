# 快速了解 uniswap_v4 

## 备注
时间：2023 年 7 月 29 日

作者：[33357](https://github.com/33357)

## 正文
uniswap_v4（以下简称 v4）改进了 uniswap_v3（以下简称 v3）的实现，以下是其中区别的快速介绍（需要对 v3 有一定程度的了解）。

### Hooks
v4 实现了 8 个回掉函数：

- beforeInitialize / afterInitialize
- beforeModifyPosition / afterModifyPosition
- beforeSwap / afterSwap
- beforeDonate / afterDonate

当有人在 v4 上创建一个 pool 时，可以指定一个 hooks 合约。通过 hooks 合约可以对 swap 和 withdrawLiquidity 操作收取费用，并自定义收费策略。或者进行其他操作。

### Singleton
v4 使用一个 contract 完成所有 token 的保管。在 v4 上创建 pool 会改变 contarct 状态，而不是像 v3 一样新建 contract。这减少了新建 pool 的 gas 费用。

### Flash Accouting
在 v3 上执行多跳 swap 需要在每个 swap 完成之后执行 transfer。但由于 Singleton，在 v4 中每个 swap 都只会更新内部 balance，仅在全部 swap 结束之后进行 transfer。这减少了多跳 swap 的 gas 费用。

### Native ETH
v4 支持原生 ETH，相比 v3 使用的 weth 减少了 Gas 的使用。

### ERC1155 Accounting
v4 使用 ERC1155 用于额外 token 的记账，用户可以将 token 保留在 contract 中，避免将 token 频繁转入或转出，以节约 gas。

### Oracle
v4 引入 hooks 使得协议内嵌的价格预言机变得不再必要，一些 pool 可以完全放弃预言机，并在每个 pool 在 block 中的第一次 swap 中节省 gas。

### Donate
v4 允许给特定范围内的流动性提供者支付 token，可以是池中的任意一种或两种代币。

## 总结
v4 对 v3 的改进主要在提出 hooks 和节约 gas 上，虽然新的使用场景还不明朗，但新协议往往就是新的机会，现在就开始研究是有价值的。

## 引用

[whitepaper-v4-draft-zh](https://github.com/33357/v4-core/blob/main/whitepaper-v4-draft-zh.pdf)

[whitepaper-v4-draft](https://github.com/33357/v4-core/blob/main/whitepaper-v4-draft.pdf)