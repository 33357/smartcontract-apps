# Compound CToken合约解析

CToken 合约是用来存。

演示代码仓库：[https://github.com/33357/compound-protocol](https://github.com/33357/compound-protocol)

### 合约初始化
- 公共函数（合约内外部都可以调用）
    - constructor
        - 代码速览
            ``` javascript
            function initialize(
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_
            ) public {
                require(msg.sender == admin, "only admin may initialize the market");
                require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");
                initialExchangeRateMantissa = initialExchangeRateMantissa_;
                require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");
                uint err = _setComptroller(comptroller_);
                require(err == uint(Error.NO_ERROR), "setting comptroller failed");
                accrualBlockNumber = getBlockNumber();
                borrowIndex = mantissaOne;
                err = _setInterestRateModelFresh(interestRateModel_);
                require(err == uint(Error.NO_ERROR), "setting interest rate model failed");
                name = name_;
                symbol = symbol_;
                decimals = decimals_;
                _notEntered = true;
            }
            ```
        - 参数分析
            函数 `initialize` 的入参有 6 个，出参有 0 个，对应的解释如下：
            ``` javascript
            function initialize(
                ComptrollerInterface comptroller_, // 审计合约
                InterestRateModel interestRateModel_, // 利率模型合约
                uint initialExchangeRateMantissa_, // 利率小数
                string memory name_, // 名字
                string memory symbol_, // 符号
                uint8 decimals_ // 小数位数
            ) public {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 只有 admin 才能初始化市场
                require(msg.sender == admin, "only admin may initialize the market");
                // 市场只能初始化一次
                require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");
                // 设置利率小数
                initialExchangeRateMantissa = initialExchangeRateMantissa_;
                require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");
                // 设置审计合约
                uint err = _setComptroller(comptroller_);
                require(err == uint(Error.NO_ERROR), "setting comptroller failed");
                // 设置块号和借用索引
                accrualBlockNumber = getBlockNumber();
                borrowIndex = mantissaOne;
                // 设置利率模型
                err = _setInterestRateModelFresh(interestRateModel_);
                require(err == uint(Error.NO_ERROR), "setting interest rate model failed");
                // 设置名字、符号、小数位数
                name = name_;
                symbol = symbol_;
                decimals = decimals_;
                // 开启防重入
                _notEntered = true;
            }
            ```
        - 总结
            函数 `initialize` 用来初始化合约，接入审计合约和利率模型合约。
### 存入资产

### 取出资产

### 借出资产

### 归还资产
- 内部（仅合约内部可以调用）
    - transferTokens
        - 代码速览
            ``` javascript
            function transferTokens(
                address spender, 
                address src,
                address dst, 
                uint tokens
            ) internal returns (uint) {
                uint allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
                if (allowed != 0) {
                    return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
                }
                if (src == dst) {
                    return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
                }
                uint startingAllowance = 0;
                if (spender == src) {
                    startingAllowance = uint(-1);
                } else {
                    startingAllowance = transferAllowances[src][spender];
                }
                MathError mathErr;
                uint allowanceNew;
                uint srcTokensNew;
                uint dstTokensNew;
                (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
                }
                (mathErr, srcTokensNew) = subUInt(accountTokens[src], tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ENOUGH);
                }
                (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_TOO_MUCH);
                }
                accountTokens[src] = srcTokensNew;
                accountTokens[dst] = dstTokensNew;
                if (startingAllowance != uint(-1)) {
                    transferAllowances[src][spender] = allowanceNew;
                }
                emit Transfer(src, dst, tokens);
                return uint(Error.NO_ERROR);
            }
            ```
        - 参数分析
            函数 `transferTokens` 的入参有 4 个，出参有 1 个，对应的解释如下：
            ``` javascript
             function transferTokens(
                address spender, // 发送者
                address src, // 来源地址
                address dst, // 目标地址
                uint tokens // 转账数量
            ) internal returns (
                uint // 错误码
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 是否授权 cToken 从 src 转账 tokens 数量的代币到 dst
                uint allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
                if (allowed != 0) {
                    return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
                }
                // src 不能等于 dst
                if (src == dst) {
                    return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
                }
                // 如果 spender == src 授权数量为无限
                uint startingAllowance = 0;
                if (spender == src) {
                    startingAllowance = uint(-1);
                } else {
                    startingAllowance = transferAllowances[src][spender];
                }
                MathError mathErr;
                uint allowanceNew;
                uint srcTokensNew;
                uint dstTokensNew;
                // 转账后 allowance 的新值
                (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
                }
                // 转账后 src 的 Tokens 新值
                (mathErr, srcTokensNew) = subUInt(accountTokens[src], tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ENOUGH);
                }
                // 转账后 dst 的 Tokens 新值
                (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
                if (mathErr != MathError.NO_ERROR) {
                    return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_TOO_MUCH);
                }
                accountTokens[src] = srcTokensNew;
                accountTokens[dst] = dstTokensNew;
                // 如果 startingAllowance 不是最大值，设置 allowance 的新值
                if (startingAllowance != uint(-1)) {
                    transferAllowances[src][spender] = allowanceNew;
                }
                emit Transfer(src, dst, tokens);
                return uint(Error.NO_ERROR);
            }
            ```
        - 总结
            函数 `transferTokens` 用来执行 cToken 的转账，主要检查了发送者地址是否有来源地址 cToken 的转账授权。

    - borrowBalanceStoredInternal
        - 代码速览
            ``` javascript
            function borrowBalanceStoredInternal(address account) internal view returns (MathError, uint) {
                MathError mathErr;
                uint principalTimesIndex;
                uint result;
                BorrowSnapshot storage borrowSnapshot = accountBorrows[account];
                if (borrowSnapshot.principal == 0) {
                    return (MathError.NO_ERROR, 0);
                }
                (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndex);
                if (mathErr != MathError.NO_ERROR) {
                    return (mathErr, 0);
                }
                (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
                if (mathErr != MathError.NO_ERROR) {
                    return (mathErr, 0);
                }
                return (MathError.NO_ERROR, result);
            }
            ```
        - 参数分析
            函数 `borrowBalanceStoredInternal` 的入参有 1 个，出参有 2 个，对应的解释如下：
            ``` javascript
            function borrowBalanceStoredInternal(
                address account // 账户地址
            ) internal view returns (
                MathError, // 错误代码
                uint // 账户余额
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                MathError mathErr;
                uint principalTimesIndex;
                uint result;
                // 账户借款快照
                BorrowSnapshot storage borrowSnapshot = accountBorrows[account];
                if (borrowSnapshot.principal == 0) {
                    return (MathError.NO_ERROR, 0);
                }
                // 借款金额 = 借款总数 * 全局利率 / 已计算个人利率
                (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndex);
                if (mathErr != MathError.NO_ERROR) {
                    return (mathErr, 0);
                }
                (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
                if (mathErr != MathError.NO_ERROR) {
                    return (mathErr, 0);
                }
                return (MathError.NO_ERROR, result);
            }
            ```
        - 总结
            函数 `borrowBalanceStoredInternal` 用来计算用户借款金额：本金+利息。

    - exchangeRateStoredInternal
        - 代码速览
            ``` javascript
            function exchangeRateStoredInternal() internal view returns (MathError, uint) {
                uint _totalSupply = totalSupply;
                if (_totalSupply == 0) {
                    return (MathError.NO_ERROR, initialExchangeRateMantissa);
                } else {
                    uint totalCash = getCashPrior();
                    uint cashPlusBorrowsMinusReserves;
                    Exp memory exchangeRate;
                    MathError mathErr;
                    (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
                    if (mathErr != MathError.NO_ERROR) {
                        return (mathErr, 0);
                    }
                    (mathErr, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
                    if (mathErr != MathError.NO_ERROR) {
                        return (mathErr, 0);
                    }
                    return (MathError.NO_ERROR, exchangeRate.mantissa);
                }
            }
            ```
        - 参数分析
            函数 `exchangeRateStoredInternal` 的入参有 0 个，出参有 2 个，对应的解释如下：
            ``` javascript
            function exchangeRateStoredInternal() internal view returns (
                MathError, // 错误代码
                uint // 交易小数
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 
                uint _totalSupply = totalSupply;
                if (_totalSupply == 0) {
                    return (MathError.NO_ERROR, initialExchangeRateMantissa);
                } else {
                    uint totalCash = getCashPrior();
                    uint cashPlusBorrowsMinusReserves;
                    Exp memory exchangeRate;
                    MathError mathErr;
                    (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
                    if (mathErr != MathError.NO_ERROR) {
                        return (mathErr, 0);
                    }
                    (mathErr, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
                    if (mathErr != MathError.NO_ERROR) {
                        return (mathErr, 0);
                    }
                    return (MathError.NO_ERROR, exchangeRate.mantissa);
                }
            }
            ```
        - 总结
            函数 `exchangeRateStoredInternal` 用来计算用户借款金额：本金+利息。

- 外部（仅合约外部可以调用）
    - getAccountSnapshot
        - 代码速览
            ``` javascript
            function getAccountSnapshot(
                address account
            ) external view returns (uint, uint, uint, uint) {
                uint cTokenBalance = accountTokens[account];
                uint borrowBalance;
                uint exchangeRateMantissa;
                MathError mErr;
                (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
                if (mErr != MathError.NO_ERROR) {
                    return (uint(Error.MATH_ERROR), 0, 0, 0);
                }
                (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
                if (mErr != MathError.NO_ERROR) {
                    return (uint(Error.MATH_ERROR), 0, 0, 0);
                }
                return (uint(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
            }
            ```
        - 参数分析
            函数 `getAccountSnapshot` 的入参有 1 个，出参有 4 个，对应的解释如下：
            ``` javascript
            function getAccountSnapshot(
                address account // 账户地址
            ) external view returns (
                uint, // 错误代码
                uint, // cToken 余额
                uint, // 借款金额
                uint // 汇率小数
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 获取 cToken 余额
                uint cTokenBalance = accountTokens[account];
                uint borrowBalance;
                uint exchangeRateMantissa;
                MathError mErr;
                // 获取借款金额
                (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
                if (mErr != MathError.NO_ERROR) {
                    return (uint(Error.MATH_ERROR), 0, 0, 0);
                }
                // 汇率小数
                (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
                if (mErr != MathError.NO_ERROR) {
                    return (uint(Error.MATH_ERROR), 0, 0, 0);
                }
                return (uint(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
            }
            ```
        - 总结
            函数 `getAccountSnapshot` 用来获取当前区块的账户数据快照，包括错误代码、cToken 余额、借款金额、汇率小数。

