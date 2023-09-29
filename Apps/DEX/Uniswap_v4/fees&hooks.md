# uniswap-v4 fees&hooks 合约分析

## 备注

时间：2023 年 9 月 1 日

作者：[33357](https://github.com/33357)

## 正文

fees 和 hooks 是 Uniswap-v4 core 的手续费和钩子合约，通过对该合约的解析可以了解其功能和对接方法。

### Fees.sol
#### 设置 protocolFeeController 地址
- 外部函数（仅合约内部可以调用）
    - setProtocolFeeController
        - 代码解析
            ``` javascript
            function setProtocolFeeController(
                IProtocolFeeController controller // controller 合约地址
            ) external onlyOwner {
                // 设置 controller 合约地址
                protocolFeeController = controller;
                // 触发 controller 合约地址更新事件
                emit ProtocolFeeControllerUpdated(address(controller));
            }
            ```
        - 总结
            函数 `setProtocolFeeController` 用于更新协议手续费控制合约地址。

#### 提取协议手续费
- 外部函数（仅合约内部可以调用）
    - collectProtocolFees
        - 代码解析
            ``` javascript
            function collectProtocolFees(
                address recipient, // 接收地址
                Currency currency, // 提取货币
                uint256 amount // 提取数量
            ) external returns (
                uint256 amountCollected // 返回已收数量
            ) {
                // 只允许 owner 和 protocolFeeController 调用
                if (msg.sender != owner && msg.sender != address(protocolFeeController)) revert InvalidCaller();
                // 如果 amount 为 0 就提取全部协议手续费
                amountCollected = (amount == 0) ? protocolFeesAccrued[currency] : amount;
                // 应计协议手续费更新
                protocolFeesAccrued[currency] -= amountCollected;
                // 转账 currency
                currency.transfer(recipient, amountCollected);
            }
            ```
        - 总结
            函数 `collectProtocolFees` 用于提取协议手续费。

#### 提取 hook 手续费
- 外部函数（仅合约内部可以调用）
    - collectHookFees
        - 代码解析
            ``` javascript
            function collectHookFees(
                address recipient, // 接收地址
                Currency currency, // 提取货币
                uint256 amount // 提取数量
            ) external returns (
                uint256 amountCollected // 返回已收数量
            ) {
                address hookAddress = msg.sender;
                // 如果提取数量为 0 就提取全部 hook 手续费
                amountCollected = (amount == 0) ? hookFeesAccrued[hookAddress][currency] : amount;
                // 如果 recipient 为 0 地址，就提取到 hook 地址
                recipient = (recipient == address(0)) ? hookAddress : recipient;
                // 应计 hook 手续费更新
                hookFeesAccrued[hookAddress][currency] -= amountCollected;
                // 转账 currency
                currency.transfer(recipient, amountCollected);
            }
            ```
        - 总结
            函数 `collectHookFees` 用于提取 hook 手续费。

#### 获取协议手续费
- 内部函数（仅合约内部可以调用）
    - _fetchProtocolFees
        - 代码解析
            ``` javascript
            function _fetchProtocolFees(
                PoolKey memory key
                /* struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
            ) internal view returns (
                uint8 protocolSwapFee, // 协议 swap 手续费
                uint8 protocolWithdrawFee // 协议提取流动性手续费
            ) {
                // protocolFeeController 不能为 0 地址
                if (address(protocolFeeController) != address(0)) {
                    // 剩余 gaslimit 必须大于等于 controllerGasLimit
                    if (gasleft() < controllerGasLimit) revert ProtocolFeeCannotBeFetched();
                    // 获取协议 swap 手续费和协议提取流动性手续费
                    try protocolFeeController.protocolFeesForPool{gas: controllerGasLimit}(key) returns (
                        uint8 updatedProtocolSwapFee, uint8 updatedProtocolWithdrawFee
                    ) {
                        protocolSwapFee = updatedProtocolSwapFee;
                        protocolWithdrawFee = updatedProtocolWithdrawFee;
                    } catch {}
                    // 检查协议 swap 手续费
                    _checkProtocolFee(protocolSwapFee);
                    // 检查协议提取流动性手续费
                    _checkProtocolFee(protocolWithdrawFee);
                }
            }
            ```
        - 总结
            函数 `_fetchProtocolFees` 用于获取协议手续费数量。

    - _checkProtocolFee
        - 代码解析
            ``` javascript
            function _checkProtocolFee(
                uint8 fee // 协议手续费
            ) internal pure {
                if (fee != 0) {
                    // fee0 是 fee 后 4 位数值
                    uint8 fee0 = fee % 16;
                    // fee1 是 fee 前 4 位数值
                    uint8 fee1 = fee >> 4;
                    // fee0 和 fee1 不为 0 的情况下不能低于 4
                    if (
                        (fee0 != 0 && fee0 < MIN_PROTOCOL_FEE_DENOMINATOR) || (fee1 != 0 && fee1 < MIN_PROTOCOL_FEE_DENOMINATOR)
                    ) {
                        revert FeeTooLarge();
                    }
                }
            }
            ```
        - 总结
            函数 `_checkProtocolFee` 用于检查协议手续费是否合规。

#### 获取 hook 手续费
- 内部函数（仅合约内部可以调用）
    - _fetchHookFees
        - 代码解析
            ``` javascript
            function _fetchHookFees(
                PoolKey memory key
                /* struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
            ) internal view returns (
                uint8 hookSwapFee, // hook swap 手续费
                uint8 hookWithdrawFee // hook 提取流动性手续费
            ) {
                // 获取 hook swap 手续费
                if (key.fee.hasHookSwapFee()) {
                    hookSwapFee = IHookFeeManager(address(key.hooks)).getHookSwapFee(key);
                }
                // 获取 hook 提取流动性手续费
                if (key.fee.hasHookWithdrawFee()) {
                    hookWithdrawFee = IHookFeeManager(address(key.hooks)).getHookWithdrawFee(key);
                }
            }
            ```
        - 总结
            函数 `_fetchHookFees` 用于获取 hook 手续费数量。

### FeeLibrary.sol
#### 设置 protocolFeeController 地址
- 内部函数（仅合约内部可以调用）
    - isDynamicFee
        - 代码解析
            ``` javascript
            function isDynamicFee(
                uint24 self // 手续费
            ) internal pure returns (
                bool // 返回是否是动态费用
            ) {
                // 是否是动态费用
                return self & DYNAMIC_FEE_FLAG != 0;
            }
            ```
        - 总结
            函数 `isDynamicFee` 用于检查手续费是否是动态费用。

    - hasHookSwapFee
        - 代码解析
            ``` javascript
            function hasHookSwapFee(
                uint24 self // 手续费
            ) internal pure returns (
                bool // 返回是否有 hook swap 手续费
            ) {
                // 是否有 hook swap 手续费
                return self & HOOK_SWAP_FEE_FLAG != 0;
            }
            ```
        - 总结
            函数 `hasHookSwapFee` 用于检查是否有 hook swap 手续费。
        
    - hasHookWithdrawFee
        - 代码解析
            ``` javascript
            function hasHookWithdrawFee(
                uint24 self // 手续费
            ) internal pure returns (
                bool // 返回是否有 hook 提取流动性手续费
            ) {
                // 是否有 hook 提取流动性手续费
                return self & HOOK_WITHDRAW_FEE_FLAG != 0;
            }
            ```
        - 总结
            函数 `hasHookWithdrawFee` 用于检查手续费是否有 hook 提取流动性手续费。
    
    - isStaticFeeTooLarge
        - 代码解析
            ``` javascript
            function isStaticFeeTooLarge(
                uint24 self // 手续费
            ) internal pure returns (
                bool // 返回是否静态手续费太高
            ) {
                // 是否静态手续费太高
                return self & STATIC_FEE_MASK >= 1000000;
            }
            ```
        - 总结
            函数 `isStaticFeeTooLarge` 用于检查手续费是否静态手续费太高。
    
    - getStaticFee
        - 代码解析
            ``` javascript
            function getStaticFee(
                uint24 self // 手续费
            ) internal pure returns (
                uint24 // 返回静态手续费
            ) {
                // 获取静态手续费
                return self & STATIC_FEE_MASK;
            }
            ```
        - 总结
            函数 `getStaticFee` 用于获取手续费的静态手续费数量。

### Hooks.sol
#### 设置 protocolFeeController 地址
- 内部函数（仅合约内部可以调用）
    - validateHookAddress
        - 代码解析
            ``` javascript
            function validateHookAddress(
                IHooks self, // hook 地址
                Calls memory calls
                /* struct Calls {
                    bool beforeInitialize; // 是否有 beforeInitialize 的 hook
                    bool afterInitialize; // 是否有 afterInitialize 的 hook
                    bool beforeModifyPosition; // 是否有 beforeModifyPosition 的 hook
                    bool afterModifyPosition; // 是否有 afterModifyPosition 的 hook
                    bool beforeSwap; // 是否有 beforeSwap 的 hook
                    bool afterSwap; // 是否有 afterSwap 的 hook
                    bool beforeDonate; // 是否有 beforeDonate 的 hook
                    bool afterDonate; // 是否有 afterDonate 的 hook
                } */
            ) internal pure {
                // 检查 hook 地址是否匹配 calls
                if (
                    calls.beforeInitialize != shouldCallBeforeInitialize(self)
                        || calls.afterInitialize != shouldCallAfterInitialize(self)
                        || calls.beforeModifyPosition != shouldCallBeforeModifyPosition(self)
                        || calls.afterModifyPosition != shouldCallAfterModifyPosition(self)
                        || calls.beforeSwap != shouldCallBeforeSwap(self) || calls.afterSwap != shouldCallAfterSwap(self)
                        || calls.beforeDonate != shouldCallBeforeDonate(self) || calls.afterDonate != shouldCallAfterDonate(self)
                ) {
                    revert HookAddressNotValid(address(self));
                }
            }
            ```
        - 总结
            函数 `validateHookAddress` 用于检查 hook 地址是否匹配 calls。

#### 设置 protocolFeeController 地址
- 内部函数（仅合约内部可以调用）
    - isValidHookAddress
        - 代码解析
            ``` javascript
            function isValidHookAddress(
                IHooks hook, // hook 地址
                uint24 fee // 手续费
            ) internal pure returns (
                bool // 返回是否是正确的 hook 地址
            ) {
                // 
                return address(hook) == address(0)
                    ? !fee.isDynamicFee() && !fee.hasHookSwapFee() && !fee.hasHookWithdrawFee()
                    : (
                        uint160(address(hook)) >= AFTER_DONATE_FLAG || fee.isDynamicFee() || fee.hasHookSwapFee()
                            || fee.hasHookWithdrawFee()
                    );
            }
            ```
        - 总结
            函数 `isValidHookAddress` 用于返回是否是有效的 hook 地址。

#### 检查是否设置 hooks
- 内部函数（仅合约内部可以调用）
    - shouldCallBeforeInitialize
        - 代码解析
            ``` javascript
            function shouldCallBeforeInitialize(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 beforeInitialize 的 hook
            ) {
                // 是否有 beforeInitialize 的 hook
                return uint256(uint160(address(self))) & BEFORE_INITIALIZE_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallBeforeInitialize` 用于检查 hook 地址是否有 beforeInitialize 的 hook。
    
    - shouldCallAfterInitialize
        - 代码解析
            ``` javascript
            function shouldCallAfterInitialize(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 afterInitialize 的 hook
            ) {
                // 是否有 afterInitialize 的 hook
                return uint256(uint160(address(self))) & AFTER_INITIALIZE_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallAfterInitialize` 用于检查 hook 地址是否有 afterInitialize 的 hook。
    
    - shouldCallBeforeModifyPosition
        - 代码解析
            ``` javascript
            function shouldCallBeforeModifyPosition(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 beforeModifyPosition 的 hook
            ) {
                // 是否有 beforeModifyPosition 的 hook
                return uint256(uint160(address(self))) & BEFORE_MODIFY_POSITION_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallBeforeModifyPosition` 用于检查 hook 地址是否有 beforeModifyPosition 的 hook。

    - shouldCallAfterModifyPosition
        - 代码解析
            ``` javascript
            function shouldCallAfterModifyPosition(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 afterModifyPosition 的 hook
            ) {
                // 是否有 afterModifyPosition 的 hook
                return uint256(uint160(address(self))) & AFTER_MODIFY_POSITION_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallAfterModifyPosition` 用于检查 hook 地址是否有 afterModifyPosition 的 hook。

    - shouldCallBeforeSwap
        - 代码解析
            ``` javascript
            function shouldCallBeforeSwap(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 beforeSwap 的 hook
            ) {
                // 是否有 beforeSwap 的 hook
                return uint256(uint160(address(self))) & BEFORE_SWAP_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallBeforeSwap` 用于检查 hook 地址是否有 beforeSwap 的 hook。

    - shouldCallAfterSwap
        - 代码解析
            ``` javascript
            function shouldCallAfterSwap(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 afterSwap 的 hook
            ) {
                // 是否有 afterSwap 的 hook
                return uint256(uint160(address(self))) & AFTER_SWAP_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallAfterSwap` 用于检查 hook 地址是否有 afterSwap 的 hook。

    - shouldCallBeforeDonate
        - 代码解析
            ``` javascript
            function shouldCallBeforeDonate(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 beforeDonate 的 hook
            ) {
                // 是否有 beforeDonate 的 hook
                return uint256(uint160(address(self))) & BEFORE_DONATE_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallBeforeDonate` 用于检查 hook 地址是否有 beforeDonate 的 hook。

    - shouldCallAfterDonate
        - 代码解析
            ``` javascript
            function shouldCallAfterDonate(
                IHooks self // hook 地址
            ) internal pure returns (
                bool // 返回是否有 afterDonate 的 hook
            ) {
                // 是否有 afterDonate 的 hook
                return uint256(uint160(address(self))) & AFTER_DONATE_FLAG != 0;
            }
            ```
        - 总结
            函数 `shouldCallAfterDonate` 用于检查 hook 地址是否有 afterDonate 的 hook。