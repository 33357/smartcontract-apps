# 选择什么语言编写智能合约

## 备注

时间：2023 年 9 月 26 日

作者：[33357](https://github.com/33357)

## 正文

我到目前为止主要接触的智能合约编写语言是 Solidity、Yul 和 Huff。虽然都是写智能合约的，但三个语言处理的业务其实不太一样，合理使用可以提高工作效率。

### Solidity
Solidity 是高级语言，有结构体、合约对象、合约继承等概念，适合复杂功能的编写。由于是绝大部分 ERC 提案和市面应用的编程语言，在智能合约的市场上有着近乎垄断的地位。

如果你打算写一个商业的开源智能合约，Solidity 就是最好的编程语言，不仅有很多工具库，接口也是最清楚的。结合 Foundry 还可以用 Solidity 编写测试，效率非常高。

### Yul
Yul 相比 Solidity 能够直接操作 opcode，是一门低级语言。由于隐藏了堆栈和控制流，在编写上和 Solidity 相似，可以和 Solidity 一起写，用于功能的 gas 优化。

相比完整的应用，Yul 更适合对在 Solidity 编写的智能合约上做局部的 Gas 优化。如果不打算开源或者商业化，纯 Yul 能写出比 Solidity 更高效的合约，因此在科学家群体中比较热门。

### Huff
Huff 能够从堆栈的层面上直接操作 opcode，在操作上比 Yul 更加底层，但因此写起来也比 Yul 繁琐的多。在 Gas 优化上Huff 能做到极致，可读性上就很难做了。

Huff 纯粹是科学家们的玩具，可以构建出一些有意思的积木，但最好不要想着直接用来造房子。如果你有兴趣，这里推荐 evm codes 可以帮助你查询和测试 opcode。

### 推荐资料
[Solidity 文档](https://docs.soliditylang.org/en/v0.8.21/)

[Foundry 文档](https://book.getfoundry.sh/)

[Yul 文档](https://docs.soliditylang.org/en/v0.8.21/yul.html)

[Huff 文档](https://docs.huff.sh/get-started/overview/)

[evm codes](https://www.evm.codes/?fork=shanghai)