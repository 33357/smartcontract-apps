# uniswap-v4 poolManager 合约分析

## 备注

时间：2023 年 8 月 13 日

作者：[33357](https://github.com/33357)

## 正文

poolManager 是 Uniswap-v4 core 的主合约，通过对改合约的解析可以了解其核心功能和对接方法。

### 创建流动池
- 公共函数（合约内外部都可以调用）
    - initialize
        - 代码解析
            ``` javascript
            function initialize(
                PoolKey memory key, /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
                uint160 sqrtPriceX96 // 价格
            ) external override returns (
                int24 tick // 返回 tick
            ) {
                // 固定手续费不能大于最大值
                if (key.fee.isStaticFeeTooLarge()) revert FeeTooLarge();
                // tick 单位间距不能大于最大值
                if (key.tickSpacing > MAX_TICK_SPACING) revert TickSpacingTooLarge();
                // tick 单位间距不能小于最小值
                if (key.tickSpacing < MIN_TICK_SPACING) revert TickSpacingTooSmall();
                // 是否是合法的 hook 地址
                if (!key.hooks.isValidHookAddress(key.fee)) revert Hooks.HookAddressNotValid(address(key.hooks));
                // 如果 hooks 地址的 shouldCallBeforeInitialize 检查通过
                if (key.hooks.shouldCallBeforeInitialize()) {
                    // 需要 beforeInitialize 返回 IHooks.beforeInitialize 的 selector
                    if (key.hooks.beforeInitialize(msg.sender, key, sqrtPriceX96) != IHooks.beforeInitialize.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 获取 poolId
                PoolId id = key.toId();
                // 获取协议手续费
                (uint8 protocolSwapFee, uint8 protocolWithdrawFee) = _fetchProtocolFees(key);
                // 获取 hook 手续费
                (uint8 hookSwapFee, uint8 hookWithdrawFee) = _fetchHookFees(key);
                // 创建资金池
                tick = pools[id].initialize(sqrtPriceX96, protocolSwapFee, hookSwapFee, protocolWithdrawFee, hookWithdrawFee);
                // 如果 hooks 地址的 shouldCallAfterInitialize 检查通过
                if (key.hooks.shouldCallAfterInitialize()) {
                     // 需要 afterInitialize 返回 IHooks.afterInitialize 的 selector
                    if (key.hooks.afterInitialize(msg.sender, key, sqrtPriceX96, tick) != IHooks.afterInitialize.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 触发 Initialize 事件
                emit Initialize(id, key.currency0, key.currency1, key.fee, key.tickSpacing, key.hooks);
            }
            ```
        - 总结
            函数 `initialize` 用于创建流动池 pool，要注意对 hook 地址的检查。

## 锁定用户
- 公共函数（合约内外部都可以调用）
    - lock
        - 代码解析
            ``` javascript
            function lock(
                bytes calldata data // 回调 data
            ) external override returns (
                bytes memory result // 返回回调结果
            ) {
                // 锁定用户
                lockData.push(msg.sender);
                // lockAcquired 回调
                result = ILockCallback(msg.sender).lockAcquired(data);
                if (lockData.length == 1) {
                    // 如果非零账单数量需要等于 0
                    if (lockData.nonzeroDeltaCount != 0) revert CurrencyNotSettled();
                    // 删除 lockData
                    delete lockData;
                } else {
                    // 删除最后一个 lockData
                    lockData.pop();
                }
            }
            ```
        - 总结
            函数 `lock` 用于锁定用户，是调用其他 `onlyByLocker` 函数的前提。

## 添加/删除流动性
- 公共函数（合约内外部都可以调用）
    - modifyPosition
        - 代码解析
            ``` javascript
           function modifyPosition(
                PoolKey memory key, /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
                IPoolManager.ModifyPositionParams memory params /* 
                struct ModifyPositionParams {
                    int24 tickLower; // 最低 tick
                    int24 tickUpper; // 最高 tick
                    int256 liquidityDelta; // 流动性数量
                } */
            ) external override noDelegateCall onlyByLocker returns (
                BalanceDelta delta // 分为 amount0 和 amount1
            ) {
                // 如果 hooks 地址的 shouldCallBeforeModifyPosition 检查通过
                if (key.hooks.shouldCallBeforeModifyPosition()) {
                    // 需要 beforeModifyPosition 返回 IHooks.beforeModifyPosition 的 selector
                    if (key.hooks.beforeModifyPosition(msg.sender, key, params) != IHooks.beforeModifyPosition.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 获取 poolId
                PoolId id = key.toId();
                Pool.FeeAmounts memory feeAmounts;
                // 改变流动池
                (delta, feeAmounts) = pools[id].modifyPosition(
                    Pool.ModifyPositionParams({
                        owner: msg.sender,
                        tickLower: params.tickLower,
                        tickUpper: params.tickUpper,
                        liquidityDelta: params.liquidityDelta.toInt128(),
                        tickSpacing: key.tickSpacing
                    })
                );
                // 改变帐单
                _accountPoolBalanceDelta(key, delta);
                unchecked {
                    // 如果 currency0 的协议手续费大于 0，就增加 currency0 的应计协议费用
                    if (feeAmounts.feeForProtocol0 > 0) {
                        protocolFeesAccrued[key.currency0] += feeAmounts.feeForProtocol0;
                    }
                    // 如果 currency1 的协议手续费大于 0，就增加 currency1 的应计协议费用
                    if (feeAmounts.feeForProtocol1 > 0) {
                        protocolFeesAccrued[key.currency1] += feeAmounts.feeForProtocol1;
                    }
                    // 如果 currency0 的 hook 手续费大于 0，就增加 currency0 的应计 hook 费用
                    if (feeAmounts.feeForHook0 > 0) {
                        hookFeesAccrued[address(key.hooks)][key.currency0] += feeAmounts.feeForHook0;
                    }
                    // 如果 currency1 的 hook 手续费大于 0，就增加 currency1 的应计 hook 费用
                    if (feeAmounts.feeForHook1 > 0) {
                        hookFeesAccrued[address(key.hooks)][key.currency1] += feeAmounts.feeForHook1;
                    }
                }
                // 如果 hooks 地址的 shouldCallAfterModifyPosition 检查通过
                if (key.hooks.shouldCallAfterModifyPosition()) {
                    // 需要 afterModifyPosition 返回 IHooks.afterModifyPosition 的 selector
                    if (key.hooks.afterModifyPosition(msg.sender, key, params, delta) != IHooks.afterModifyPosition.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 触发 ModifyPosition 事件
                emit ModifyPosition(id, msg.sender, params.tickLower, params.tickUpper, params.liquidityDelta);
            }
            ```
        - 总结
            函数 `modifyPosition` 用于添加/删除流动性。

- 内部函数（仅合约内部可以调用）
    - _accountPoolBalanceDelta
        - 代码解析
            ``` javascript
            function _accountPoolBalanceDelta(
                PoolKey memory key, /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
                BalanceDelta delta // 分为 amount0 和 amount1
            ) internal {
                // 增加 amount0 数量的 currency0 帐单
                _accountDelta(key.currency0, delta.amount0());
                // 增加 amount1 数量的 currency1 帐单
                _accountDelta(key.currency1, delta.amount1());
            }
            ```
        - 总结
            函数 `_accountPoolBalanceDelta` 用于同时改变 `currency0` 和 `currency1` 的账单。

    - _accountDelta
        - 代码解析
            ``` javascript
            function _accountDelta(
                Currency currency, // currency 地址
                int128 delta // 操作数量
            ) internal {
                // delta 不能为 0
                if (delta == 0) return;
                // 获取 lock 用户地址
                address locker = lockData.getActiveLock();
                // 获取 lock 用户的 currency 帐单数量
                int256 current = currencyDelta[locker][currency];
                // 完账数量
                int256 next = current + delta;
                unchecked {
                    if (next == 0) {
                        // 如果完账数量为 0，非零账单数量减一
                        lockData.nonzeroDeltaCount--;
                    } else if (current == 0) {
                        // 如果完账数量不为 0，并且帐单数量为 0，非零账单数量加一
                        lockData.nonzeroDeltaCount++;
                    }
                }
                // 完账数量记上账单
                currencyDelta[locker][currency] = next;
            }
            ```
        - 总结
            函数 `_accountDelta` 用于改变用户账单。

## swap 交易
- 公共函数（合约内外部都可以调用）
    - swap
        - 代码解析
            ``` javascript
            function swap(
                PoolKey memory key, /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
                IPoolManager.SwapParams memory params /* 
                struct SwapParams {
                    bool zeroForOne; // swap 方向
                    int256 amountSpecified; // 指定数量
                    uint160 sqrtPriceLimitX96; // 价格限制
                } */
            ) external override noDelegateCall onlyByLocker returns (
                BalanceDelta delta // 
            ) {
                // 如果 hooks 地址的 shouldCallBeforeSwap 检查通过
                if (key.hooks.shouldCallBeforeSwap()) {
                    // 需要 beforeSwap 返回 IHooks.beforeSwap 的 selector
                    if (key.hooks.beforeSwap(msg.sender, key, params) != IHooks.beforeSwap.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                uint24 totalSwapFee;
                if (key.fee.isDynamicFee()) {
                    // 获取动态费用
                    totalSwapFee = IDynamicFeeManager(address(key.hooks)).getFee(key);
                    // 总费用不能大于 1000000
                    if (totalSwapFee >= 1000000) revert FeeTooLarge();
                } else {
                    // 获取固定费用
                    totalSwapFee = key.fee.getStaticFee();
                }
                uint256 feeForProtocol;
                uint256 feeForHook;
                Pool.SwapState memory state;
                // 获取 poolId
                PoolId id = key.toId();
                // swap 交易
                (delta, feeForProtocol, feeForHook, state) = pools[id].swap(
                    Pool.SwapParams({
                        fee: totalSwapFee,
                        tickSpacing: key.tickSpacing,
                        zeroForOne: params.zeroForOne,
                        amountSpecified: params.amountSpecified,
                        sqrtPriceLimitX96: params.sqrtPriceLimitX96
                    })
                );
                // 改变帐单
                _accountPoolBalanceDelta(key, delta);
                unchecked {
                    // 如果协议手续费大于 0，就增加应计协议费用
                    if (feeForProtocol > 0) {
                        protocolFeesAccrued[params.zeroForOne ? key.currency0 : key.currency1] += feeForProtocol;
                    }
                    // 如果 hook 手续费大于 0，就增加应计 hook 费用
                    if (feeForHook > 0) {
                        hookFeesAccrued[address(key.hooks)][params.zeroForOne ? key.currency0 : key.currency1] += feeForHook;
                    }
                }
                // 如果 hooks 地址的 shouldCallAfterSwap 检查通过
                if (key.hooks.shouldCallAfterSwap()) {
                    // 需要 afterSwap 返回 IHooks.afterSwap 的 selector
                    if (key.hooks.afterSwap(msg.sender, key, params, delta) != IHooks.afterSwap.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 触发 Swap 事件
                emit Swap(id,msg.sender,delta.amount0(),delta.amount1(),state.sqrtPriceX96,state.liquidity,state.tick,totalSwapFee
                );
            }
            ```
        - 总结
            函数 `swap` 用于执行交易。

## 捐赠
- 公共函数（合约内外部都可以调用）
    - donate
        - 代码解析
            ``` javascript
            function donate(
                PoolKey memory key, /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
                uint256 amount0, // 地址数值较小 currency 的数量
                uint256 amount1 // 地址数值较大 currency 的数量
            ) external override noDelegateCall onlyByLocker returns (
                BalanceDelta delta // 分为 amount0 和 amount1
            ) {
                // 如果 hooks 地址的 shouldCallBeforeDonate 检查通过
                if (key.hooks.shouldCallBeforeDonate()) {
                    // 需要 beforeDonate 返回 IHooks.beforeDonate 的 selector
                    if (key.hooks.beforeDonate(msg.sender, key, amount0, amount1) != IHooks.beforeDonate.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
                // 向资金池捐赠 amount0 和 amount1
                delta = _getPool(key).donate(amount0, amount1);
                // 改变帐单
                _accountPoolBalanceDelta(key, delta);
                // 如果 hooks 地址的 shouldCallAfterDonate 检查通过
                if (key.hooks.shouldCallAfterDonate()) {
                    // 需要 afterDonate 返回 IHooks.afterDonate 的 selector
                    if (key.hooks.afterDonate(msg.sender, key, amount0, amount1) != IHooks.afterDonate.selector) {
                        revert Hooks.InvalidHookResponse();
                    }
                }
            }
            ```
        - 总结
            函数 `donate` 用于向流动池捐赠 `currency0` 和 `currency1`。

## 获取 currency
- 公共函数（合约内外部都可以调用）
    - take
        - 代码解析
            ``` javascript
            function take(
                Currency currency, // currency 地址
                address to, // to 地址
                uint256 amount // 数量
            ) external override noDelegateCall onlyByLocker {
                // 增加 amount 数量的 currency 帐单
                _accountDelta(currency, amount.toInt128());
                // currency 储备数量减少 amount
                reservesOf[currency] -= amount;
                // 向 to 地址发送 amount 数量的 currency
                currency.transfer(to, amount);
            }
            ```
        - 总结
            函数 `take` 可以直接向 v4 借 `currency`。

## 铸造 ERC1155
- 公共函数（合约内外部都可以调用）
    - mint
        - 代码解析
            ``` javascript
            function mint(
                Currency currency, // currency 地址
                address to, // to 地址
                uint256 amount // 数量
            ) external override noDelegateCall onlyByLocker {
                // 增加 amount 数量的 currency 帐单
                _accountDelta(currency, amount.toInt128());
                // mint ERC1155
                _mint(to, currency.toId(), amount, "");
            }
            ```
        - 总结
            函数 `mint` 可以直接从 v4 铸造 ERC1155。

## 结清 currency
- 公共函数（合约内外部都可以调用）
    - settle
        - 代码解析
            ``` javascript
            function settle(
                Currency currency // currency 地址
            ) external payable override noDelegateCall onlyByLocker returns (
                uint256 paid // 回收数量
            ) {
                // 获取 currency 储备数量
                uint256 reservesBefore = reservesOf[currency];
                // 更新 currency 储备数量
                reservesOf[currency] = currency.balanceOfSelf();
                // 获取增加的 currency 储备数量
                paid = reservesOf[currency] - reservesBefore;
                // 减少 paid 数量的 currency 帐单
                _accountDelta(currency, -(paid.toInt128()));
            }
            ```
        - 总结
            函数 `settle` 用于向 v4 结清 currency。

## 结清 ERC1155
- 公共函数（合约内外部都可以调用）
    - onERC1155Received
        - 代码解析
            ``` javascript
            function onERC1155Received(
                address, address,
                uint256 id, // tokenId
                uint256 value, // 数量
                bytes calldata
            ) external returns (
                bytes4 // IERC1155Receiver.onERC1155Received 的 selector
            ) {
                // 只允许合约回调
                if (msg.sender != address(this)) revert NotPoolManagercurrency();
                // 销毁并修改账单
                _burnAndAccount(CurrencyLibrary.fromId(id), value);
                // 返回 IERC1155Receiver.onERC1155Received 的 selector
                return IERC1155Receiver.onERC1155Received.selector;
            }
            ```
        - 总结
            函数 `onERC1155Received` 用于向 v4 结清 ERC1155。

    - onERC1155BatchReceived
        - 代码解析
            ``` javascript
            function onERC1155BatchReceived(
                address,
                address,
                uint256[] calldata ids, // tokenId 列表
                uint256[] calldata values, // 数量列表
                bytes calldata
            ) external returns (
                bytes4 // IERC1155Receiver.onERC1155Received 的 selector
            ) {
                // 只允许合约回调
                if (msg.sender != address(this)) revert NotPoolManagercurrency();
                unchecked {
                    // 批量销毁并修改账单
                    for (uint256 i; i < ids.length; i++) {
                        _burnAndAccount(CurrencyLibrary.fromId(ids[i]), values[i]);
                    }
                }
                // 返回 IERC1155Receiver.onERC1155Received 的 selector
                return IERC1155Receiver.onERC1155BatchReceived.selector;
            }
            ```
        - 总结
            函数 `onERC1155BatchReceived` 用于向 v4 批量结清 ERC1155。

- 内部函数（仅合约内部可以调用）
    - _burnAndAccount
        - 代码解析
            ``` javascript
            function _burnAndAccount(
                Currency currency, // currency 地址
                uint256 amount // currency 数量
            ) internal {
                // 销毁 amount 数量的 currency
                _burn(address(this), currency.toId(), amount);
                // 减少 amount 数量的 currency 帐单
                _accountDelta(currency, -(amount.toInt128()));
            }
            ```
        - 总结
            函数 `_burnAndAccount` 用于燃烧 ERC1155 并改变账单。

### 设置协议手续费
- 公共函数（合约内外部都可以调用）
    - setProtocolFees
        - 代码解析
            ``` javascript
            function setProtocolFees(
                PoolKey memory key /* 
                struct PoolKey {
                    Currency currency0; // pool 中数值较小的 currency 地址
                    Currency currency1; // pool 中数值较大的 currency 地址
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
            ) external {
                // 获取协议手续费
                (uint8 newProtocolSwapFee, uint8 newProtocolWithdrawFee) = _fetchProtocolFees(key);
                // 获取 poolId
                PoolId id = key.toId();
                // 设置协议手续费
                pools[id].setProtocolFees(newProtocolSwapFee, newProtocolWithdrawFee);
                // 触发协议手续费更新事件
                emit ProtocolFeeUpdated(id, newProtocolSwapFee, newProtocolWithdrawFee);
            }
            ```
        - 总结
            函数 `setProtocolFees` 用于设置协议手续费。

### 设置 hook 手续费
- 公共函数（合约内外部都可以调用）
    - setHookFees
        - 代码解析
            ``` javascript
            function setHookFees(
                PoolKey memory key /* 
                struct PoolKey {
                    Currency currency0; // pool 中地址数值较小的 currency
                    Currency currency1; // pool 中地址数值较大的 currency
                    uint24 fee; // 手续费
                    int24 tickSpacing; // tick 单位间距
                    IHooks hooks; // hooks 地址
                } */
            ) external {
                // 获取 hook 手续费
                (uint8 newHookSwapFee, uint8 newHookWithdrawFee) = _fetchHookFees(key);
                // 获取 poolId
                PoolId id = key.toId();
                // 设置 hook 手续费
                pools[id].setHookFees(newHookSwapFee, newHookWithdrawFee);
                // 触发 hook 手续费更新事件
                emit HookFeeUpdated(id, newHookSwapFee, newHookWithdrawFee);
            }
            ```
        - 总结
            函数 `setHookFees` 用于设置 hook 手续费。