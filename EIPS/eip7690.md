# 反闪电贷协议 EIP7690
## 备注
时间：2024 年 6 月 23 日

作者：[33357](https://github.com/33357)

## 正文

闪电贷虽然能快速磨平市场价差，提高市场流动性，但同时也方便了黑客进套取大额资金。最近一个新的 EIP7690 利用以太坊坎昆升级新特性 TSTORE/TLOAD，能够很好地阻止闪电贷，为加密市场提供了更多选择。

https://github.com/ethereum/ERCs/pull/382

### 闪电贷原理

闪电贷的原理并不复杂，只要你能在同一笔交易中向资金池完成借出和归还同样数量的token，资金池就认为这笔闪电贷交易是安全的，你可以获得资金池的大额借款去做任何事情。

### EIP7690 分析

EIP7690 通过限制同一笔交易中，同一个函数的调用次数来达到阻止闪电贷的效果。比如闪电贷操作中至少要调用两次 transfer 来实现借出和归还 token，但如果该 token 使用 EIP7690 限制同一笔交易中只能调用一次 transfer，那么就无法同时完成借出和归还的操作，也就无法实现闪电贷了。

不仅是闪电贷，EIP7690 也会阻止批量转账等需要多次调用 transfer 的功能，因此使用 EIP7690 也要评估其对现有合约的兼容性。

``` javascript
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC7690 {
    // 增加 Function 调用次数
    function addFunctionCallTimes(bytes4 selector) internal {
        assembly {
            // 读取 Function 调用次数
            let i := tload(selector)
            // Function 调用次数加 1
            i := add(i, 1)
            // 存储 Function 调用次数
            tstore(selector, i)
        }
    }

    // 获取 Function 调用次数
    function getFunctionCallTimes(bytes4 selector)
        external
        view
        returns (uint256 i)
    {
        assembly {
            i := tload(selector)
        }
    }
}

contract PreventingFlashLoansToken is ERC20, ERC7690 {
    constructor() ERC20("PreventingFlashLoansToken", "PFT") {}

    function _update(address from, address to, uint256 value) internal override {
        // 检查 Function 调用次数为 0
        require(this.getFunctionCallTimes(IERC20.transfer.selector) == 0, "Only one transfer possible");
        // 增加 Function 调用次数
        addFunctionCallTimes(IERC20.transfer.selector);
        _update(from, to, value);
    }
}
```

由于 tstore 存储在交易结束之后会回滚状态，因此不会影响到同区块中的其他交易。对于同一笔交易中的临时变量存储，tstore 的确是非常好的工具。

### 总结

EIP7690 并不完美，但也许能对现在的加密市场带来一些改变。
