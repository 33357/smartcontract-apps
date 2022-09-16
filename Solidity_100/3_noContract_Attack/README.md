# 合约检查攻击

## 原理分析

合约检查攻击：为了防止被第三方合约调用而产生攻击，经常会拒绝来自合约地址的调用，但有的情况下可以绕过合约检查从而进行攻击。

- 合约检查

检查一个地址是否为合约地址，一般有两种方法：`tx.orgin == msg.sender` 或者 `assembly { size := extcodesize(account) }`。

- 合约检查攻击

`tx.orgin == msg.sender` 一般来说是安全的，但 `assembly { size := extcodesize(account) }` 是可以绕过并实现攻击的。

## 流程图示

- 合约检查
```mermaid
graph TB
    start[方法开始] --> check[检查调用者是否为合约地址] -- 是 --> endIt[终止执行]
    check -- 否 --> runIt[继续执行]
```

- 合约检查攻击
```mermaid

```

## 示例代码

这是一个简单的 Bank 合约示例，它的功能是存入和提现 Ether。如果你看不出合约的问题，说明你正需要学习这节课。(这个合约有巨大漏洞，请不要直接使用在任何实际业务中)

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

contract Bank {
    mapping(address => uint256) public balance;

    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balance[msg.sender] - amount > 0, "Bank: Insufficient balance");
        balance[msg.sender] -= amount;
        msg.sender.call{value: amount}("");
    }
}
```

## 演示流程

1. 打开 [https://remix.ethereum.org/](https://remix.ethereum.org/)

2. 选择 solidity 版本为 0.8.12，部署 Bank 合约。

3. 将 Bank 合约地址作为参数部署 ReentrancyAttack 合约。

4. value 选择 1 Ether，点击 Bank 合约的 deposit 方法，存入 1 Ether。

5. value 选择 1 Ether，点击 ReentrancyAttack 合约的 doDeposit 方法，存入 1 Ether。

6. 点击 Bank 合约的 totalDeposit 方法，是 2 Ether，点击 Bank 合约的 ethBalance 方法，也是 2 Ether。

7. 点击 ReentrancyAttack 合约的 doWithdraw 方法，进行重入攻击。

8. 点击 Bank 合约的 totalDeposit 方法，是 1 Ether，点击 Bank 合约的 ethBalance 方法，却是 0 Ether。

9. 使用 Bank 合约的 balance 方法查看 ReentrancyAttack 合约地址和合约创建者，发现合约创建者 balance 为 1 Ether，但是合约里已经没有 Ether 可以提供兑付。

## 修复问题

- 禁止重入
    ```solidity
    boolean public entered;

    modifier nonReentrant() {
        require(!entered, "Bank: reentrant call");
        entered = true;
        _;
        entered = false;
    }

    function withdraw() nonReentrant external {
        require(balance[msg.sender] > 0, "Bank: no balance");
        msg.sender.call{value: balance[msg.sender]}("");
        totalDeposit -= balance[msg.sender];
        balance[msg.sender] = 0;
    }
    ```
    使用 nonReentrant 来禁止合约重入，可以防止重入攻击。这里推荐使用 openzeppelin 的官方防重入合约 `@openzeppelin/contracts/security/ReentrancyGuard.sol`。

- 在提现 Ether 或者调用第三方合约之前，先修改合约状态
    ```solidity
    function withdraw() external {
        require(balance[msg.sender] > 0, "Bank: no balance");
        uint256 _balance = balance[msg.sender];
        totalDeposit -= balance[msg.sender];
        balance[msg.sender] = 0;
        msg.sender.call{value: _balance}(""); 
    }
    ```
    优先修改合约状态，虽然不能禁止合约重入，但可以避免被重入攻击。

- 禁止转账 Ether 到合约地址
    ```solidity
    function withdraw() nonReentrant external {
        require(balance[msg.sender] > 0, "Bank: no balance");
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size == 0, "Bank: cannot transfer to contract");
        msg.sender.call{value: balance[msg.sender]}("");
        totalDeposit -= balance[msg.sender];
        balance[msg.sender] = 0;
    }
    ```
    禁止转账 Ether 到合约地址，可以防止转账 Ether 导致的合约重入。
