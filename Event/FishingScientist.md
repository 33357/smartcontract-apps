# 警惕科学家钓鱼合约

## 备注

时间：2024 年 6 月 30 日

作者：[33357](https://github.com/33357)

## 正文

有个朋友给我发了一个合约 https://etherscan.io/address/0x8876a8cf6e142a0aeb834b824e97870111bb7da1 说有套利可能，可以来研究。我发现这的确是一个有明显漏洞的合约，里面还有 15 ETH 的资金。但仔细研究过后发现这是专门用来钓鱼的合约，想要去攻击的智能合约新手很容易上当。

### 代码分析

``` javascript
/**
 *Submitted for verification at Etherscan.io on 2024-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract smart_bank {
    function Deposit(uint _unlockTime) public payable {
        Holder storage acc = Accounts[msg.sender];
        acc.balance += msg.value;
        acc.unlockTime = _unlockTime > block.timestamp ? _unlockTime : block.timestamp;
        LogFile.AddMessage(msg.sender, msg.value, "Put");
    }

    function Collect(uint _am) public payable {
        Holder storage acc = Accounts[msg.sender];
        if (acc.balance > MinSum && acc.balance >= _am && block.timestamp > acc.unlockTime) {
            (bool success, ) = msg.sender.call{value: _am}("");
            if (success) {
                acc.balance -= _am;
                LogFile.AddMessage(msg.sender, _am, "Collect");
            }
        }
    }

    struct Holder {
        uint unlockTime;
        uint balance;
    }

    mapping(address => Holder) public Accounts;

    Log LogFile;

    uint public MinSum = 1 ether;

    constructor(address log) {
        LogFile = Log(log);
    }

    fallback() external payable {
        Deposit(0);
    }

    receive() external payable {
        Deposit(0);
    }
}

contract Log {
    event Message(address indexed Sender, string Data, uint Val, uint Time);

    function AddMessage(address _adr, uint _val, string memory _data) external {
        emit Message(_adr, _data, _val, block.timestamp);
    }
}
```
这个合约有两个明显的漏洞：
1. 在 `msg.sender.call` 之后调用 `acc.balance -= _am`, 而且没有重入锁，可以使用重入攻击。
2. 在 0.7.6 的 solidity 版本之下使用 `acc.balance -= _am`，可以使用整数溢出攻击。

但如果你想当然的去用上面的手段攻击合约，就上合约部署者的当了。

这个合约有一个奇怪的方法 `LogFile.AddMessage`，虽然在下面给出了 `contract Log` 的源代码，看起来没有问题，但在合约初始化是没有使用 `LogFile = new Log()` 而是使用了 `LogFile = Log(log)`，这导致了 `LogFile.AddMessage` 函数调用的代码其实在其他地址。

### 代码溯源

通过分析合约构造交易的 https://etherscan.io/tx/0x9cb838f7b2eb28951fc2d0b560f8bb98ce32b1789b00735c89385fd9740c96e2 的 `data`，可以找到 logFile 的真实合约地址是 https://etherscan.io/address/0x441f6fb6e9506082625fe0b973025ef65badf584 ，而这个合约并没有开源。使用反编译工具可以一窥究竟 https://etherscan.io/bytecode-decompiler?a=0x441f6fb6e9506082625fe0b973025ef65badf584

``` python
# Palkeoramix decompiler. 

def storage:
  stor0 is addr at storage 0
  stor1 is addr at storage 1
  stor2 is addr at storage 2

def _fallback() payable: # default function
  revert

def unknown4b906714(addr _param1, uint256 _param2, array _param3) payable: 
  if stor1 != tx.origin:
      require tx.origin == stor2
  call _param1 with:
     value _param2 wei
       gas gas_remaining wei
      args _param3[all]
  require ext_call.success

def AddMessage(address _adr, uint256 _val, string _data): # not payable
  log 0xb7206ff2: Array(len=_data.length, data=_data[all]), _val, block.timestamp, _adr
  if caller == stor0:
      if stor1 != tx.origin:
          if stor2 != tx.origin:
              if _val > 0:
                  require 0 < _data.length
                  require Mask(8, 248, cd[(_data + 36)]) != 'C'
```

可以看到 `AddMessage` 函数的真实逻辑是：
1. 检查 caller 是否为 stor0，如果是则进入下一步
2. 检查 tx.origin 是否是 stor1 或者 stor2，如果不是则进入下一步
3. 检查 _val 是否大于 0，如果是则进入下一步
4. _data 长度必须大于 0，并且首字母不能是 `C`

所以当别人调用 `Deposit` 往合约里存 ETH 的时候可以正常执行，但调用 `Collect` 向合约取 ETH 的时候会触发首字母不能是 `C` 的检查，从而无法执行。

### 总结

科学家的收入虽然吸引人，但经验不足的新手很容易掉坑里。最近也出现了一些专门钓鱼科学家的合约，大家要谨慎检查。