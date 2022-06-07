# Compound RateModel合约解析

RateModel合约是用来计算 Compound 上特定代币借贷利率的合约，分析它可以知道借贷利率的计算方法。

演示代码仓库：[https://github.com/33357/compound-protocol](https://github.com/33357/compound-protocol)

## WhitePaperInterestRateModel.sol 

直线型利率模型

### 合约初始化
- 公共函数（合约内外部都可以调用）
    - constructor
        - 代码速览
            ``` javascript
            constructor(uint baseRatePerYear, uint multiplierPerYear) public {
                baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
                multiplierPerBlock = multiplierPerYear.div(blocksPerYear);
                emit NewInterestParams(baseRatePerBlock, multiplierPerBlock);
            }
            ```
        - 参数分析
            函数 `constructor` 的入参有 2 个，出参有 0 个，对应的解释如下：
            ``` javascript
            constructor(
                uint baseRatePerYear, // 年基准利率
                uint multiplierPerYear // 年利率乘数
            ) public {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 块基准利率 = 年基准利率 / 年块数
                baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
                // 块利率乘数 = 年利率乘数 / 年块数
                multiplierPerBlock = multiplierPerYear.div(blocksPerYear);
                // 触发事件 NewInterestParams
                emit NewInterestParams(baseRatePerBlock, multiplierPerBlock);
            }
            ```
        - 总结
            合约需要按 `block` 作为时间单位来计算利率，因此需要将 `baseRatePerYear` 和 `multiplierPerYear` 转换为 `baseRatePerBlock` 和 `multiplierPerBlock`。这里的 `blocksPerYear` 为 `2102400`，是按照平均 `15秒` 一个 `block` 计算的。
### 资金借出率
- 公共函数（合约内外部都可以调用）
    - utilizationRate
        - 代码速览
            ``` javascript
            function utilizationRate(uint cash, uint borrows, uint reserves) public pure returns (uint) {
                if (borrows == 0) {
                    return 0;
                }
                return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
            }
            ```
        - 参数分析
            函数 `utilizationRate` 的入参有 3 个，出参有 1 个，对应的解释如下：
            ``` javascript
            constructor(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves // 储备代币总数
            ) public view returns (
                uint // 资金借出率
            ){
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 如果借出代币总数为 0，资金借出率也为 0
                if (borrows == 0) {
                    return 0;
                }
                // borrows * 1e18 / (cash + borrows - reserves)
                return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
            }
            ```
        - 总结
             `utilizationRate` 用于计算代币的 `资金借出率`，`资金借出率` 的计算公式为 `资金借出率 = 借出代币总数 / (代币余额 + 借出代币总数 - 储备代币总数)`。由于使用无符号整数计算 `资金借出率` 会精度不够，所以需要乘以 `1e18`，扩大精度范围。
### 资金利率
- 公共函数（合约内外部都可以调用）
    - getBorrowRate
        - 代码速览
            ``` javascript
            function getBorrowRate(uint cash, uint borrows, uint reserves) public view returns (uint) {
                uint ur = utilizationRate(cash, borrows, reserves);
                return ur.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
            }
            ```
        - 参数分析
            函数 `getBorrowRate` 的入参有 3 个，出参有 1 个，对应的解释如下：
            ``` javascript
            function getBorrowRate(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves // 储备代币总数
            ) public view returns (
                uint // 块借出利率
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 计算资金借出率
                uint ur = utilizationRate(cash, borrows, reserves);
                // ur * multiplierPerBlock / 1e18 + baseRatePerBlock
                return ur.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
            }
            ```
        - 总结
            `getBorrowRate` 用于计算代币的 `块借出利率`，`块借出利率` 的计算公式为 `块借出利率 = 资金借出率 * 块利率乘数 + 块基准利率`。由于 `资金借出率` 扩大了精度范围，需要除以 `1e18` 得到实际值。
    - getSupplyRate
        - 代码速览
            ``` javascript
            function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) public view returns (uint) {
                uint oneMinusReserveFactor = uint(1e18).sub(reserveFactorMantissa);
                uint borrowRate = getBorrowRate(cash, borrows, reserves);
                uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
                return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
            }
            ```
        - 参数分析
            函数 `getSupplyRate` 的入参有 4 个，出参有 1 个，对应的解释如下：
            ``` javascript
            getSupplyRate(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves, // 储备代币总数
                uint reserveFactorMantissa // 储备金率
            ) public view returns (
                uint // 块质押利率
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 1 - reserveFactorMantissa
                uint oneMinusReserveFactor = uint(1e18).sub(reserveFactorMantissa);
                // 获取借款利率 borrowRate
                uint borrowRate = getBorrowRate(cash, borrows, reserves);
                // borrowRate * (1 - reserveFactorMantissa)
                uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
                // utilizationRate * borrowRate * (1 - reserveFactorMantissa)
                return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
            }
            ```
        - 总结
            `getSupplyRate` 用于计算代币的 `块质押利率`，`块质押利率` 的计算公式为 `块质押利率 = 资金借出率 * 借款利率 * (1 - 储备金率) = 借款利率 * 资金借出率 * (1 - 储备金率)`。由于 `资金借出率` 扩大了精度范围，需要除以 `1e18` 得到实际值。
        
## BaseJumpRateModelV2.sol 

拐点型利率模型

### 合约初始化
- 内部函数（仅合约内可以调用）
    - constructor
        - 代码速览
            ``` javascript
            constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_, address owner_) internal {
                owner = owner_;
                updateJumpRateModelInternal(baseRatePerYear,  multiplierPerYear, jumpMultiplierPerYear, kink_);
            }
            ```
        - 参数分析
            函数 `constructor` 的入参有 5 个，出参有 0 个，对应的解释如下：
            ``` javascript
            constructor(
                uint baseRatePerYear, // 年基准利率
                uint multiplierPerYear // 年利率乘数
                uint jumpMultiplierPerYear, // 拐点年利率乘数
                uint kink_, // 拐点资金借出率
                address owner_ // 所有者
            ) internal {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 记录所有者
                owner = owner_;
                // 更新拐点利率模型参数
                updateJumpRateModelInternal(baseRatePerYear,  multiplierPerYear, jumpMultiplierPerYear, kink_);
            }
            ```
        - 总结
            `拐点型利率模型` 比 `直线型利率模型` 多了 `拐点年利率乘数` 和 `拐点资金借出率` 这两个参数。
    - updateJumpRateModelInternal
        - 代码速览
            ``` javascript
            function updateJumpRateModelInternal(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_) internal {
                baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
                multiplierPerBlock = (multiplierPerYear.mul(1e18)).div(blocksPerYear.mul(kink_));
                jumpMultiplierPerBlock = jumpMultiplierPerYear.div(blocksPerYear);
                kink = kink_;
                emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
            }
            ```
        - 参数分析
            函数 `updateJumpRateModelInternal` 的入参有 4 个，出参有 0 个，对应的解释如下：
            ``` javascript
            function updateJumpRateModelInternal(
                uint baseRatePerYear, // 年基准利率
                uint multiplierPerYear // 年利率乘数
                uint jumpMultiplierPerYear, // 拐点年利率乘数
                uint kink_, // 拐点资金借出率
            ) internal {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 块基准利率 = 年基准利率 / 年块数
                baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
                // 块利率乘数 = 年基准利率 / (年块数 * 拐点资金借出率)
                multiplierPerBlock = (multiplierPerYear.mul(1e18)).div(blocksPerYear.mul(kink_));
                // 拐点块利率乘数 = 拐点年利率乘数 / 年块数
                jumpMultiplierPerBlock = jumpMultiplierPerYear.div(blocksPerYear);
                // 记录拐点资金借出率
                kink = kink_;
                // 触发事件 NewInterestParams
                emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
            }
            ```
        - 总结
            `拐点型利率模型` 中计算 `块利率乘数` 时，方法和 `直线型利率模型` 不一样：`拐点资金借出率` 越高，`块利率乘数` 越低，其目的我不是很清楚。(可能是拐点资金借出率越高的代币市场深度越好，块利率乘数可以设置的更低，大家可以讨论一下)
### 资金借出率
- 公共函数（合约内外部都可以调用）
    - utilizationRate
        - 代码速览
            ``` javascript
            function utilizationRate(uint cash, uint borrows, uint reserves) public pure returns (uint) {
                if (borrows == 0) {
                    return 0;
                }
                return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
            }
            ```
        - 参数分析
            函数 `utilizationRate` 的入参有 3 个，出参有 1 个，对应的解释如下：
            ``` javascript
            constructor(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves // 储备代币总数
            ) public view returns (
                uint // 资金借出率
            ){
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 如果借出代币总数为 0，资金借出率也为 0
                if (borrows == 0) {
                    return 0;
                }
                // 资金借出率 = borrows * 1e18 / (cash + borrows - reserves)
                return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
            }
            ```
        - 总结
            `拐点型利率模型` 中计算 `资金借出率` 和 `直线型利率模型` 相同。
### 资金利率
- 内部函数（仅合约内部可以调用）
    - getBorrowRate
        - 代码速览
            ``` javascript
            function getBorrowRateInternal(uint cash, uint borrows, uint reserves) internal view returns (uint) {
                uint util = utilizationRate(cash, borrows, reserves);
                if (util <= kink) {
                    return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
                } else {
                    uint normalRate = kink.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
                    uint excessUtil = util.sub(kink);
                    return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);
                }
            }
            ```
        - 参数分析
            函数 `getBorrowRateInternal` 的入参有 3 个，出参有 1 个，对应的解释如下：
            ``` javascript
            function getBorrowRate(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves // 储备代币总数
            ) internal view returns (
                uint // 块借出利率
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            {
                // 获取资金借出率 util
                uint util = utilizationRate(cash, borrows, reserves);
                // 如果 util < kink
                if (util <= kink) {
                    // return util * multiplierPerBlock + baseRatePerBlock
                    return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
                } else {
                    // 拐点前块借出利率 = kink * multiplierPerBlock + baseRatePerBlock
                    uint normalRate = kink.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
                    // 超出拐点资金借出率 = util - kink
                    uint excessUtil = util.sub(kink);
                    // 块借出利率 = (util - kink) * jumpMultiplierPerBlock + kink * multiplierPerBlock + baseRatePerBlock
                    return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);
                }
            }
            ```
        - 总结
            `拐点型利率模型` 中计算 `块借出利率` 的计算公式分为两部份：在 `资金借出率` 低于 `拐点资金借出率` 时，计算公式为：`块借出利率 = 资金借出率 * 块利率乘数 + 块基准利率`；在 `资金借出率` 高于 `拐点资金借出率` 时，计算公式为：`块借出利率 = (资金借出率 - 拐点资金借出率) * 拐点块利率乘数 + 拐点资金借出率 * 块利率乘数 + 块基准利率`。
    - getSupplyRate
        - 代码速览
            ``` javascript
            function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) public view returns (uint) {
                uint oneMinusReserveFactor = uint(1e18).sub(reserveFactorMantissa);
                uint borrowRate = getBorrowRateInternal(cash, borrows, reserves);
                uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
                return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
            }
            ```
        - 参数分析
            函数 `getSupplyRate` 的入参有 4 个，出参有 1 个，对应的解释如下：
            ``` javascript
            getSupplyRate(
                uint cash, // 代币余额
                uint borrows, // 用户借出代币总数
                uint reserves, // 储备代币总数
                uint reserveFactorMantissa // 储备金率
            ) public view returns (
                uint // 块质押利率
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 1 - reserveFactorMantissa
                uint oneMinusReserveFactor = uint(1e18).sub(reserveFactorMantissa);
                // 获取借款利率 borrowRate
                uint borrowRate = getBorrowRateInternal(cash, borrows, reserves);
                // rateToPool = borrowRate * (1 - reserveFactorMantissa)
                uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
                // 块质押利率 = utilizationRate * borrowRate * (1 - reserveFactorMantissa)
                return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
            }
            ```
        - 总结
             `拐点型利率模型` 中计算 `资金质押利率` 和 `直线型利率模型` 相同。
