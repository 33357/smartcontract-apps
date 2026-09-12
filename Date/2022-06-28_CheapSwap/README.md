# CheapSwap 协议的诞生

## 为什么会有CheapSwap

如果你想要从中心化交易所提现 USDT 到 ETH 链上，一定会被其高昂的手续费所吓到。以 Binance 为例，提现 ETH 到 ERC20 仅需 1.4 USDT的手续费，而提现 USDT 到 ERC20 却需要整整 10 USDT 的手续费。很明显的是，USDT 的转账手续费并没有 ETH 转账手续费的 7 倍之多，这就是交易所故意设置的，其目的就是为了让大家出 USDT 的时候多付一些钱。

然而 CheapSwap 协议开发者从中心化交易所的体现流程中发现了漏洞。以 Binance 为例，当用户提现 ETH 的时候，binance 会发送一笔 gasLimit 为 207128，maxFeePerGas为 102 的 ETH 转账交易。这笔交易的 maxFee 高达 0.021127056 ETH，远高于用户提现花费的 1.4 USDT。

因此，CheapSwap 协议希望利用这个漏洞，帮助用户只花费提现 ETH 到 ERC20 的费用，完成提现 USDT 到 ERC20 的工作。

## CheapSwap 协议原理

CheapSwap 协议利用了 Binance 提现 ETH 时给到的多余手续费，在提现 ETH 的同时在 UNISWAP_V3 上将 ETH 换成 USDT，并将 USDT 发送到用户的账户。

为了实现这个功能，用户需要在 CheapSwapFactory 合约上创建一个合约账户，这个合约会记录用户地址和需要换成的 TOKEN 地址。用户只需要在 Binance 上将 ETH 提现到这个合约地址，就会自动完成所有操作。

CheapSwap 协议会对该功能的每一次调用统一收取 0.001 ETH 的手续费，以帮助该协议的发展。

## 如何使用 CheapSwap 协议

1. 打开 CheapSwapFactory 合约网址
[https://etherscan.io/address/0xb5852e69be43f4f71fe656144485d2b2675bdb7a#writeContract](https://etherscan.io/address/0xb5852e69be43f4f71fe656144485d2b2675bdb7a#writeContract)

2. 点击 `connet to web3` 连接钱包

3. 点击 `createTokenOutAddress`, 输入 USDT 合约地址 `0xdAC17F958D2ee523a2206206994597C13D831ec7`, 点击 `write`, 等待钱包确认交易。

4. 钱包确认后点击 `read Contract`，点击 `tokenOutAddressMap`, 第一个输入你的钱包地址，第二个输入 USDT 合约地址 `0xdAC17F958D2ee523a2206206994597C13D831ec7`，点击 `Query`, 获得你的 ETH 提现地址。

5.在 Binance 上正常提现 ETH 到 你的 ETH 提现地址，交易确认后你就会获得等额的 USDT。

## CheapSwap 协议的问题

1. CheapSwap协议 目前依托于 Binance 的 ETH 提现漏洞而存在，如果 Binance 修复该问题，CheapSwap协议 需要另外找交易所。

2. 由于链上交易的特殊性，CheapSwap协议 不适用于大额 USDT 提现。建议提现金额少于 3000 USDT。

## CheapSwap 协议的发展

如果 Binance 持续允许 CheapSwap 协议持续利用其多余的提现费用，那么 CheapSwap 协议会陆续支持更多币种的优惠提现功能。如果有其他开发者想要利用的话，CheapSwap 协议也会提供技术方面的支持。

## 项目开源地址

CheapSwap协议已经开源，github地址为 [https://github.com/33357/cheap-swap-contract](https://github.com/33357/cheap-swap-contract)


