# 比最小代理更小的代理合约
## 备注
时间：2023 年 9 月 17 日

作者：[33357](https://github.com/33357)

## 正文
看过我写的[EIP7511 最小代理合约解析](./eip7511.md)，就能发现如果舍弃一些功能，可以写出比最小代理更小的代理合约。

### 全功能最小代理
```
合约字节码：
365f5f375f5f365f73bebebebebebebebebebebebebebebebebebebebe5af43d5f5f3e5f3d91602a57fd5bf3
运行gas: 192

部署字节码：
602c8060095f395ff3365f5f375f5f365f73bebebebebebebebebebebebebebebebebebebebe5af43d5f5f3e5f3d91602a57fd5bf3
部署gas: 8828
```

#### 场景
可以用于所有代理交易。

### 没有返回值
#### 字节码
```
合约字节码：
365f5f375f5f365f73bebebebebebebebebebebebebebebebebebebebe5af4
运行gas: 162

部署字节码：
601f8060095f395ff3365f5f375f5f365f73bebebebebebebebebebebebebebebebebebebebe5af4
部署gas: 6222
```

#### 分析
- 复制 CALLDATA 到内存

| 执行位置 | 字节码 | 操作名 | 堆栈 | 内存 | 说明 ｜
|----|----|--------------|---------|----------|---------------------------------------------|
| 00 | 36 | CALLDATASIZE | cds     |          | 将 calldatasize 计为 cds，并压入堆栈 |
| 01 | 5f | PUSH0        | 0 cds   |          | 将 0 压入堆栈 |
| 02 | 5f | PUSH0        | 0 0 cds |          | 将 0 压入堆栈 |
| 03 | 37 | CALLDATACOPY |         | calldata | 将 0 - cds 的 calldata 复制到从 0 开始的内存空间 |

- DELEGATECALL

| 执行位置 | 字节码 | 操作名 | 堆栈 | 内存 | 说明 ｜
|----|---------|----------------|-----------------------|----------|-----------------------------------|
| 04 | 5f      | PUSH0          | 0                     | calldata | 将 0 压入堆栈 |
| 05 | 5f      | PUSH0          | 0 0                   | calldata | 将 0 压入堆栈 |
| 06 | 36      | CALLDATASIZE   | cds 0 0               | calldata | 将 calldatasize 计为 cds，并压入堆栈 |
| 07 | 5f      | PUSH0          | 0 cds 0 0             | calldata | 将 0 压入堆栈 |
| 08 | 73bebe. | PUSH20 0xbebe. | 0xbebe. 0 cds 0 0     | calldata | 将 20 个字节的数据压入堆栈 |
| 1d | 5a      | GAS            | gas 0xbebe. 0 cds 0 0 | calldata | 将 gas 压入堆栈 |
| 1e | f4      | DELEGATECALL   | suc                   | calldata | 将 0 - cds 的内存数据作为参数执行 0xbebe. 地址的代码，将执行是否成功计为 suc，并压入堆栈 |

#### 场景
用于不需要返回值的代理交易。

### 没有参数和返回值
#### 字节码
```
合约字节码：
5f5f5f5f73bebebebebebebebebebebebebebebebebebebebe5af4
运行gas: 153

部署字节码：
601b8060095f395ff35f5f5f5f73bebebebebebebebebebebebebebebebebebebebe5af4
部署gas: 5422
```

#### 分析
- DELEGATECALL

| 执行位置 | 字节码 | 操作名 | 堆栈 | 内存 | 说明 ｜
|----|---------|----------------|---------------------|-|------------------------|
| 01 | 5f      | PUSH0          | 0                   | | 将 0 压入堆栈 |
| 02 | 5f      | PUSH0          | 0 0                 | | 将 0 压入堆栈 |
| 03 | 5f      | PUSH0          | 0 0 0               | | 将 0 压入堆栈 |
| 04 | 5f      | PUSH0          | 0 0 0 0             | | 将 0 压入堆栈 |
| 05 | 73bebe. | PUSH20 0xbebe. | 0xbebe. 0 0 0 0     | | 将 20 个字节的数据压入堆栈 |
| 19 | 5a      | GAS            | gas 0xbebe. 0 0 0 0 | | 将 gas 压入堆栈 |
| 1a | f4      | DELEGATECALL   | suc                 | | 将 0 - 0 的内存数据作为参数执行 0xbebe. 地址的代码，将执行是否成功计为 suc，并压入堆栈 |

#### 场景
用于不需要参数和返回值的代理交易。

### 没有参数、返回值和指定代理地址
#### 字节码
```
合约字节码：
5f5f5f5f335af4
运行gas: 154

部署字节码：
60078060095f395ff35f5f5f5f335af4
部署gas: 1622
```

#### 分析
- DELEGATECALL

| 执行位置 | 字节码 | 操作名 | 堆栈 | 内存 | 说明 ｜
|----|----|--------------|--------------------|-|------------------------|
| 01 | 5f | PUSH0        | 0                  | | 将 0 压入堆栈 |
| 02 | 5f | PUSH0        | 0 0                | | 将 0 压入堆栈 |
| 03 | 5f | PUSH0        | 0 0 0              | | 将 0 压入堆栈 |
| 04 | 5f | PUSH0        | 0 0 0 0            | | 将 0 压入堆栈 |
| 05 | 33 | CALLER       | caller 0 0 0 0     | | 将调用地址压入堆栈 |
| 06 | 5a | GAS          | gas caller 0 0 0 0 | | 将 gas 压入堆栈 |
| 07 | f4 | DELEGATECALL | suc                | | 将 0 - 0 的内存数据作为参数执行 caller 地址的代码，将执行是否成功计为 suc，并压入堆栈 |

#### 场景
用于不需要参数、返回值和指定代理地址的代理交易。

## 总结
针对不同功能修改最小代理合约可以实现更低的 GAS 消耗。