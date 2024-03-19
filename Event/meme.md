# 让 EVM 再次伟大，用智能合约保证 MEME 的安全

## 备注

时间：2024 年 3 月 19 日

作者：[33357](https://github.com/33357)

## 正文

最近 MEME 爆火，但都 2024 年了，为什么还在用给普通账号打钱的方式做 MEME？是嫌钱太多跑路太慢吗？用智能合约可以完成 MEME 从发行到上市的全部流程，而且不可能跑路。智能合约是一个伟大的发明，无脑 FUD 不可取，时间会证明 EVM 的伟大！

### 起一个名字比如 AVAXMEME，设定期限为 3 天，目标额度为 1000 AVAX，完不成退款
```javascript
    // deadline 为 3 天后
    uint256 public immutable deadline = block.timestamp + 3 days;
    // 退款时间为 deadline 之后 1 小时
    uint256 public immutable refundTime = block.timestamp + 3 days + 1 hours;
    // 目标额度为 1000 AVAX
    uint256 public immutable targetAmount = 1000 ether;
    // LP 是否开启，默认为 false
    bool public LPopen;

    // 全称为 AVAXMEME，符号为 AVME
    constructor() ERC20("AVAXMEME", "AVME") {}
```

### 接受 AVAX 转账必须在 1-100 之间，过期不候，冲 1 个 AVAX 送 10000 个 AVAXMEME，单个账户最高额度 100 AVAX
```javascript
    receive() external payable {
        // 不能低于 1 AVAX
        require(msg.value >= 1 ether, "less than 1 AVAX");
        // 不能高于 100 AVAX
        require(msg.value <= 100 ether, "greater than 100 AVAX");
        // 要在截止日期之前
        require(block.timestamp < deadline, "deadline reached");
        // 1 个 AVAX 送 10000 个 AVAXMEME
        _mint(msg.sender, 10000 * msg.value);
        // 单个账户额度不能高于 100 AVAX
        require(balanceOf(msg.sender) <= 10000 * 100 ether, "reached limit of 100 AVAX");
    }
```

### LP 开启之前禁止转账
```javascript
    function _transfer(address from, address to, uint256 amount) override internal {
        // LPopen 为 true 才能转账
        require(LPopen, "too early");
        super._transfer(from, to, amount);
    }
```

### 退款时间到没有开启 LP，退回 AVAX，支持主动退款和批量退款
```javascript
    function _refund(address sender) internal {
        // 需要在 refundTime 之后
        require(block.timestamp >= refundTime, "wait refundTime");
        // 不能在 LP 开启后
        require(!LPopen, "LP opened");
        uint256 balance = balanceOf(sender);
        // 回收 AVAXMEME
        _burn(sender, balance);
        // 退回 AVAX
        payable(sender).transfer(balance / 10000);
    }

    function refund() external {
        // 给自己退款
        _refund(msg.sender);
    }

    function batchRefund(address[] memory senderList) external {
        for (uint256 i; i < senderList.length; i++) {
            // 批量退款
            _refund(senderList[i]);
        }
    }
```

### 截止日期之后额度达标可以开启 LP，添加池子流动性为所有 AVAX + 1/4 总量的 AVAXMEME，LP 全部燃烧
```javascript
    function openLP() external {
        // deadline 之前不能开启 LP
        require(block.timestamp >= deadline,"wait deadline");
        // 不能在 LP 开启后
        require(!LPopen, "LP opened");
        uint256 amountWAVAX = address(this).balance;
        // 达不到目标额度不能开启 LP
        require(amountWAVAX >= targetAmount, "target not reached");
        IWETH WAVAX = IWETH(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
        // 创建 uniswapV2 的池子
        address pair = IUniswapV2Factory(0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C).createPair(
            address(this),
            address(WAVAX)
        );
        // AVAX 换成 WAVAX
        WAVAX.deposit{value: amountWAVAX}();
        // 添加池子流动性，所有 WAVAX + 1/4 总量的 AVAXMEME
        WAVAX.transfer(pair, amountWAVAX);
        _mint(pair, totalSupply() / 4);
        // 燃烧 LP
        IUniswapV2Pair(pair).mint(address(0));
        // LPopen 变成 true
        LPopen = true;
    }
```

## 结语

完整代码在 AVAX 地址 https://snowtrace.io/address/0x09515534BdB84dc2Fa79C7a537F00a60Ca4bd693 ，只要正确使用智能合约，MEME 就不可能跑路，对代码而不是某个人的信任会让 EVM 再次伟大。
