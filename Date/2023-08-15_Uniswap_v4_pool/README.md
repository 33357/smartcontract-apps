# uniswap-v4 pool 合约分析

## 备注

时间：2023 年 8 月 15 日

作者：[33357](https://github.com/33357)

## 正文

pool 是 Uniswap-v4 core 的流动池合约，通过对该合约的解析可以了解流动池的功能和对接方法。

### 创建流动池
- 内部函数（仅合约内部可以调用）
    - initialize
        - 代码解析
            ``` javascript
            function initialize(
                State storage self,
                uint160 sqrtPriceX96, // 价格
                uint8 protocolSwapFee, // 协议 swap 手续费
                uint8 hookSwapFee, // hook swap 手续费
                uint8 protocolWithdrawFee, // 协议提取流动性手续费
                uint8 hookWithdrawFee // hook 提取流动性手续费
            ) internal returns (
                int24 tick // 返回 tick
            ) {
                // 需要是未创建过的 pool
                if (self.slot0.sqrtPriceX96 != 0) revert PoolAlreadyInitialized();
                // 获取 tick
                tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
                // slot0 赋值
                self.slot0 = Slot0({
                    sqrtPriceX96: sqrtPriceX96,
                    tick: tick,
                    protocolSwapFee: protocolSwapFee,
                    hookSwapFee: hookSwapFee,
                    protocolWithdrawFee: protocolWithdrawFee,
                    hookWithdrawFee: hookWithdrawFee
                });
            }
            ```
        - 总结
            函数 `initialize` 用于创建流动性 pool。

### 添加/移除流动性
- 内部函数（仅合约内部可以调用）
    - modifyPosition
        - 代码解析
            ``` javascript
            function modifyPosition(
                State storage self, 
                ModifyPositionParams memory params /* 
                struct ModifyPositionParams {
                    int24 tickLower; // 最低 tick
                    int24 tickUpper; // 最高 tick
                    int256 liquidityDelta; // 流动性数量
                } */
            ) internal returns (
                BalanceDelta result, // 分为 amount0 和 amount1
                FeeAmounts memory fees /*
                struct FeeAmounts {
                    uint256 feeForProtocol0; // 
                    uint256 feeForProtocol1;
                    uint256 feeForHook0;
                    uint256 feeForHook1;
                } */
            ) {
                // 不能是未创建过的 pool
                if (self.slot0.sqrtPriceX96 == 0) revert PoolNotInitialized();
                // 检查 tick 范围
                checkTicks(params.tickLower, params.tickUpper);
                uint256 feesOwed0;
                uint256 feesOwed1;
                {
                    /* 
                    struct ModifyPositionState {
                        bool flippedLower;
                        uint128 liquidityGrossAfterLower;
                        bool flippedUpper;
                        uint128 liquidityGrossAfterUpper;
                        uint256 feeGrowthInside0X128;
                        uint256 feeGrowthInside1X128;
                    } */
                    ModifyPositionState memory state;
                    if (params.liquidityDelta != 0) {
                        // 
                        (state.flippedLower, state.liquidityGrossAfterLower) =
                            updateTick(self, params.tickLower, params.liquidityDelta, false);
                        (state.flippedUpper, state.liquidityGrossAfterUpper) =
                            updateTick(self, params.tickUpper, params.liquidityDelta, true);
                        if (params.liquidityDelta > 0) {
                            // 获取每个 tick 的最大流动性
                            uint128 maxLiquidityPerTick = tickSpacingToMaxLiquidityPerTick(params.tickSpacing);
                            if (state.liquidityGrossAfterLower > maxLiquidityPerTick) {
                                revert TickLiquidityOverflow(params.tickLower);
                            }
                            if (state.liquidityGrossAfterUpper > maxLiquidityPerTick) {
                                revert TickLiquidityOverflow(params.tickUpper);
                            }
                        }
                        if (state.flippedLower) {
                            self.tickBitmap.flipTick(params.tickLower, params.tickSpacing);
                        }
                        if (state.flippedUpper) {
                            self.tickBitmap.flipTick(params.tickUpper, params.tickSpacing);
                        }
                    }
                    (state.feeGrowthInside0X128, state.feeGrowthInside1X128) =
                        getFeeGrowthInside(self, params.tickLower, params.tickUpper);
                    (feesOwed0, feesOwed1) = self.positions.get(params.owner, params.tickLower, params.tickUpper).update(
                        params.liquidityDelta, state.feeGrowthInside0X128, state.feeGrowthInside1X128
                    );
                    if (params.liquidityDelta < 0) {
                        if (state.flippedLower) {
                            clearTick(self, params.tickLower);
                        }
                        if (state.flippedUpper) {
                            clearTick(self, params.tickUpper);
                        }
                    }
                }
                if (params.liquidityDelta != 0) {
                    if (self.slot0.tick < params.tickLower) {
                        result = result
                            + toBalanceDelta(
                                SqrtPriceMath.getAmount0Delta(
                                    TickMath.getSqrtRatioAtTick(params.tickLower),
                                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                                    params.liquidityDelta
                                ).toInt128(),
                                0
                            );
                    } else if (self.slot0.tick < params.tickUpper) {
                        result = result
                            + toBalanceDelta(
                                SqrtPriceMath.getAmount0Delta(
                                    self.slot0.sqrtPriceX96, TickMath.getSqrtRatioAtTick(params.tickUpper), params.liquidityDelta
                                ).toInt128(),
                                SqrtPriceMath.getAmount1Delta(
                                    TickMath.getSqrtRatioAtTick(params.tickLower), self.slot0.sqrtPriceX96, params.liquidityDelta
                                ).toInt128()
                            );
                        self.liquidity = params.liquidityDelta < 0
                            ? self.liquidity - uint128(-params.liquidityDelta)
                            : self.liquidity + uint128(params.liquidityDelta);
                    } else {
                        result = result
                            + toBalanceDelta(
                                0,
                                SqrtPriceMath.getAmount1Delta(
                                    TickMath.getSqrtRatioAtTick(params.tickLower),
                                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                                    params.liquidityDelta
                                ).toInt128()
                            );
                    }
                }
                if (params.liquidityDelta < 0 && self.slot0.hookWithdrawFee > 0) {
                    fees = _calculateExternalFees(self, result);
                    result = result
                        + toBalanceDelta(
                            fees.feeForHook0.toInt128() + fees.feeForProtocol0.toInt128(),
                            fees.feeForHook1.toInt128() + fees.feeForProtocol1.toInt128()
                        );
                }
                result = result - toBalanceDelta(feesOwed0.toInt128(), feesOwed1.toInt128());
            }
            ```
        - 总结
            函数 `modifyPosition` 用于添加/删除流动性。

    - checkTicks
        - 代码解析
            ``` javascript
            function checkTicks(
                int24 tickLower, // 低 tick
                int24 tickUpper // 高 tick
            ) private pure {
                // 低 tick 不能高于 高 tick
                if (tickLower >= tickUpper) revert TicksMisordered(tickLower, tickUpper);
                // 低 tick 不能低于最小 tick
                if (tickLower < TickMath.MIN_TICK) revert TickLowerOutOfBounds(tickLower);
                // 高 tick 不能高于最高 tick
                if (tickUpper > TickMath.MAX_TICK) revert TickUpperOutOfBounds(tickUpper);
            }
            ```
        - 总结
            函数 `checkTicks` 用于检查 tick。

    - updateTick
        - 代码解析
            ``` javascript
            function updateTick(
                State storage self, 
                int24 tick, // tick
                int128 liquidityDelta,
                bool upper
            ) internal returns (
                bool flipped, 
                uint128 liquidityGrossAfter
            ) {
                TickInfo storage info = self.ticks[tick];
                uint128 liquidityGrossBefore;
                int128 liquidityNetBefore;
                assembly {
                    let liquidity := sload(info.slot)
                    liquidityGrossBefore := shr(128, shl(128, liquidity))
                    liquidityNetBefore := shr(128, liquidity)
                }
                liquidityGrossAfter = liquidityDelta < 0
                    ? liquidityGrossBefore - uint128(-liquidityDelta)
                    : liquidityGrossBefore + uint128(liquidityDelta);
                flipped = (liquidityGrossAfter == 0) != (liquidityGrossBefore == 0);
                if (liquidityGrossBefore == 0) {
                    if (tick <= self.slot0.tick) {
                        info.feeGrowthOutside0X128 = self.feeGrowthGlobal0X128;
                        info.feeGrowthOutside1X128 = self.feeGrowthGlobal1X128;
                    }
                }
                int128 liquidityNet = upper ? liquidityNetBefore - liquidityDelta : liquidityNetBefore + liquidityDelta;
                assembly {
                    sstore(
                        info.slot,
                        or(
                            liquidityGrossAfter,
                            shl(128, liquidityNet)
                        )
                    )
                }
            }
            ```
        - 总结
            函数 `updateTick` 用于更新 tick。

    - tickSpacingToMaxLiquidityPerTick
        - 代码解析
            ``` javascript
            function tickSpacingToMaxLiquidityPerTick(
                int24 tickSpacing // 单位 tick
            ) internal pure returns (
                uint128
            ) {
                unchecked {
                    // 单位 tick 转换成每个 tick 的最大流动性
                    return uint128(
                        (type(uint128).max * uint256(int256(tickSpacing)))
                            / uint256(int256(TickMath.MAX_TICK * 2 + tickSpacing))
                    );
                }
            }
            ```
        - 总结
            函数 `tickSpacingToMaxLiquidityPerTick` 用于将单位 tick 转换成每个 tick 的最大流动性。

    - getFeeGrowthInside
        - 代码解析
            ``` javascript
            function getFeeGrowthInside(
                State storage self, 
                int24 tickLower, // 低 tick
                int24 tickUpper // 高 tick
            ) internal view returns (
                uint256 feeGrowthInside0X128, 
                uint256 feeGrowthInside1X128
            ) {
                // 获取低 tick
                TickInfo storage lower = self.ticks[tickLower];
                // 获取高 tick
                TickInfo storage upper = self.ticks[tickUpper];
                int24 tickCurrent = self.slot0.tick;
                unchecked {
                    if (tickCurrent < tickLower) {
                        feeGrowthInside0X128 = lower.feeGrowthOutside0X128 - upper.feeGrowthOutside0X128;
                        feeGrowthInside1X128 = lower.feeGrowthOutside1X128 - upper.feeGrowthOutside1X128;
                    } else if (tickCurrent >= tickUpper) {
                        feeGrowthInside0X128 = upper.feeGrowthOutside0X128 - lower.feeGrowthOutside0X128;
                        feeGrowthInside1X128 = upper.feeGrowthOutside1X128 - lower.feeGrowthOutside1X128;
                    } else {
                        feeGrowthInside0X128 =
                            self.feeGrowthGlobal0X128 - lower.feeGrowthOutside0X128 - upper.feeGrowthOutside0X128;
                        feeGrowthInside1X128 =
                            self.feeGrowthGlobal1X128 - lower.feeGrowthOutside1X128 - upper.feeGrowthOutside1X128;
                    }
                }
            }
            ```
        - 总结
            函数 `getFeeGrowthInside` 用于获取内部增长手续费。

    - clearTick
        - 代码解析
            ``` javascript
            function clearTick(
                State storage self, 
                int24 tick // tick
            ) internal {
                // 删除 tick
                delete self.ticks[tick];
            }
            ```
        - 总结
            函数 `clearTick` 用于删除 tick。

    - _calculateExternalFees
        - 代码解析
            ``` javascript
            function _calculateExternalFees(
                State storage self, 
                BalanceDelta result // 分为 amount0 和 amount1
            ) internal view returns (
                FeeAmounts memory fees /*
                struct FeeAmounts {
                    uint256 feeForProtocol0; // 
                    uint256 feeForProtocol1;
                    uint256 feeForHook0;
                    uint256 feeForHook1;
                } */
            ) {
                // 获取 amount0
                int128 amount0 = result.amount0();
                // 获取 amount1
                int128 amount1 = result.amount1();
                // 
                uint8 hookFee0 = self.slot0.hookWithdrawFee % 16;
                uint8 hookFee1 = self.slot0.hookWithdrawFee >> 4;
                uint8 protocolFee0 = self.slot0.protocolWithdrawFee % 16;
                uint8 protocolFee1 = self.slot0.protocolWithdrawFee >> 4;
                if (amount0 < 0 && hookFee0 > 0) {
                    fees.feeForHook0 = uint128(-amount0) / hookFee0;
                }
                if (amount1 < 0 && hookFee1 > 0) {
                    fees.feeForHook1 = uint128(-amount1) / hookFee1;
                }
                // 计算 token0 的手续费
                if (protocolFee0 > 0 && fees.feeForHook0 > 0) {
                    fees.feeForProtocol0 = fees.feeForHook0 / protocolFee0;
                    fees.feeForHook0 -= fees.feeForProtocol0;
                }
                // 计算 token1 的手续费
                if (protocolFee1 > 0 && fees.feeForHook1 > 0) {
                    fees.feeForProtocol1 = fees.feeForHook1 / protocolFee1;
                    fees.feeForHook1 -= fees.feeForProtocol1;
                }
                return fees;
            }
            ```
        - 总结
            函数 `_calculateExternalFees` 用于计算外部手续费。

### swap 交易
- 内部函数（仅合约内部可以调用）
    - swap
        - 代码解析
            ``` javascript
            function swap(
                State storage self, 
                SwapParams memory params /* 
                struct SwapParams {
                    bool zeroForOne; // swap 方向
                    int256 amountSpecified; // 指定数量
                    uint160 sqrtPriceLimitX96; // 价格限制
                } */
            ) internal returns (
                BalanceDelta result, // 分为 amount0 和 amount1
                uint256 feeForProtocol, // 协议手续费
                uint256 feeForHook, // hook 手续费
                SwapState memory state /*
                struct SwapState {
                    int256 amountSpecifiedRemaining;
                    int256 amountCalculated;
                    uint160 sqrtPriceX96;
                    int24 tick;
                    uint256 feeGrowthGlobalX128;
                    uint128 liquidity;
                } */
            ) {
                // 指定数量不能是 0
                if (params.amountSpecified == 0) revert SwapAmountCannotBeZero();
                Slot0 memory slot0Start = self.slot0;
                // 不能是未创建过的 pool
                if (slot0Start.sqrtPriceX96 == 0) revert PoolNotInitialized();
                if (params.zeroForOne) {
                    // 不能超过价格上限
                    if (params.sqrtPriceLimitX96 >= slot0Start.sqrtPriceX96) {
                        revert PriceLimitAlreadyExceeded(slot0Start.sqrtPriceX96, params.sqrtPriceLimitX96);
                    }
                    // 不能低于价格下限
                    if (params.sqrtPriceLimitX96 <= TickMath.MIN_SQRT_RATIO) {
                        revert PriceLimitOutOfBounds(params.sqrtPriceLimitX96);
                    }
                } else {
                    // 不能低于价格下限
                    if (params.sqrtPriceLimitX96 <= slot0Start.sqrtPriceX96) {
                        revert PriceLimitAlreadyExceeded(slot0Start.sqrtPriceX96, params.sqrtPriceLimitX96);
                    }
                     // 不能超过价格上限
                    if (params.sqrtPriceLimitX96 >= TickMath.MAX_SQRT_RATIO) {
                        revert PriceLimitOutOfBounds(params.sqrtPriceLimitX96);
                    }
                }
                // SwapCache 赋值
                SwapCache memory cache = SwapCache({
                    liquidityStart: self.liquidity,
                    protocolFee: params.zeroForOne ? (slot0Start.protocolSwapFee % 16) : (slot0Start.protocolSwapFee >> 4),
                    hookFee: params.zeroForOne ? (slot0Start.hookSwapFee % 16) : (slot0Start.hookSwapFee >> 4)
                });
                // 是否
                bool exactInput = params.amountSpecified > 0;
                // SwapState 赋值
                state = SwapState({
                    amountSpecifiedRemaining: params.amountSpecified,
                    amountCalculated: 0,
                    sqrtPriceX96: slot0Start.sqrtPriceX96,
                    tick: slot0Start.tick,
                    feeGrowthGlobalX128: params.zeroForOne ? self.feeGrowthGlobal0X128 : self.feeGrowthGlobal1X128,
                    liquidity: cache.liquidityStart
                });
                StepComputations memory step;
                while (state.amountSpecifiedRemaining != 0 && state.sqrtPriceX96 != params.sqrtPriceLimitX96) {
                    step.sqrtPriceStartX96 = state.sqrtPriceX96;
                    (step.tickNext, step.initialized) =
                        self.tickBitmap.nextInitializedTickWithinOneWord(state.tick, params.tickSpacing, params.zeroForOne);
                    if (step.tickNext < TickMath.MIN_TICK) {
                        step.tickNext = TickMath.MIN_TICK;
                    } else if (step.tickNext > TickMath.MAX_TICK) {
                        step.tickNext = TickMath.MAX_TICK;
                    }
                    step.sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(step.tickNext);
                    (state.sqrtPriceX96, step.amountIn, step.amountOut, step.feeAmount) = SwapMath.computeSwapStep(
                        state.sqrtPriceX96,
                        (
                            params.zeroForOne
                                ? step.sqrtPriceNextX96 < params.sqrtPriceLimitX96
                                : step.sqrtPriceNextX96 > params.sqrtPriceLimitX96
                        ) ? params.sqrtPriceLimitX96 : step.sqrtPriceNextX96,
                        state.liquidity,
                        state.amountSpecifiedRemaining,
                        params.fee
                    );
                    if (exactInput) {
                        unchecked {
                            state.amountSpecifiedRemaining -= (step.amountIn + step.feeAmount).toInt256();
                        }
                        state.amountCalculated = state.amountCalculated - step.amountOut.toInt256();
                    } else {
                        unchecked {
                            state.amountSpecifiedRemaining += step.amountOut.toInt256();
                        }
                        state.amountCalculated = state.amountCalculated + (step.amountIn + step.feeAmount).toInt256();
                    }
                    if (cache.protocolFee > 0) {
                        uint256 delta = step.feeAmount / cache.protocolFee;
                        unchecked {
                            step.feeAmount -= delta;
                            feeForProtocol += delta;
                        }
                    }
                    if (cache.hookFee > 0) {
                        uint256 delta = step.feeAmount / cache.hookFee;
                        unchecked {
                            step.feeAmount -= delta;
                            feeForHook += delta;
                        }
                    }
                    if (state.liquidity > 0) {
                        unchecked {
                            state.feeGrowthGlobalX128 += FullMath.mulDiv(step.feeAmount, FixedPoint128.Q128, state.liquidity);
                        }
                    }
                    if (state.sqrtPriceX96 == step.sqrtPriceNextX96) {
                        if (step.initialized) {
                            int128 liquidityNet = Pool.crossTick(
                                self,
                                step.tickNext,
                                (params.zeroForOne ? state.feeGrowthGlobalX128 : self.feeGrowthGlobal0X128),
                                (params.zeroForOne ? self.feeGrowthGlobal1X128 : state.feeGrowthGlobalX128)
                            );
                            unchecked {
                                if (params.zeroForOne) liquidityNet = -liquidityNet;
                            }

                            state.liquidity = liquidityNet < 0
                                ? state.liquidity - uint128(-liquidityNet)
                                : state.liquidity + uint128(liquidityNet);
                        }
                        unchecked {
                            state.tick = params.zeroForOne ? step.tickNext - 1 : step.tickNext;
                        }
                    } else if (state.sqrtPriceX96 != step.sqrtPriceStartX96) {
                        state.tick = TickMath.getTickAtSqrtRatio(state.sqrtPriceX96);
                    }
                }
                (self.slot0.sqrtPriceX96, self.slot0.tick) = (state.sqrtPriceX96, state.tick);
                if (cache.liquidityStart != state.liquidity) self.liquidity = state.liquidity;
                if (params.zeroForOne) {
                    self.feeGrowthGlobal0X128 = state.feeGrowthGlobalX128;
                } else {
                    self.feeGrowthGlobal1X128 = state.feeGrowthGlobalX128;
                }
                unchecked {
                    if (params.zeroForOne == exactInput) {
                        result = toBalanceDelta(
                            (params.amountSpecified - state.amountSpecifiedRemaining).toInt128(),
                            state.amountCalculated.toInt128()
                        );
                    } else {
                        result = toBalanceDelta(
                            state.amountCalculated.toInt128(),
                            (params.amountSpecified - state.amountSpecifiedRemaining).toInt128()
                        );
                    }
                }
            }
            ```
        - 总结
            函数 `swap` 用于交易 token。

    - crossTick
        - 代码解析
            ``` javascript
            function crossTick(
                State storage self, 
                int24 tick, // tick
                uint256 feeGrowthGlobal0X128, 
                uint256 feeGrowthGlobal1X128
            ) internal returns (
                int128 liquidityNet
            ) {
                unchecked {
                    TickInfo storage info = self.ticks[tick];
                    info.feeGrowthOutside0X128 = feeGrowthGlobal0X128 - info.feeGrowthOutside0X128;
                    info.feeGrowthOutside1X128 = feeGrowthGlobal1X128 - info.feeGrowthOutside1X128;
                    liquidityNet = info.liquidityNet;
                }
            }
            ```
        - 总结
            函数 `crossTick` 用于 tick。

### 捐赠
- 内部函数（仅合约内部可以调用）
    - donate
        - 代码解析
            ``` javascript
            function donate(
                State storage state, 
                uint256 amount0, // amount0
                uint256 amount1 // amount1
            ) internal returns (
                BalanceDelta delta  // 分为 amount0 和 amount1
            ) {
                // 不能是未创建过的 pool
                if (state.liquidity == 0) revert NoLiquidityToReceiveFees();
                // 获取 delta
                delta = toBalanceDelta(amount0.toInt128(), amount1.toInt128());
                unchecked {
                    // 如果 amount0 大于 0，捐赠 token0 到流动性
                    if (amount0 > 0) {
                        state.feeGrowthGlobal0X128 += FullMath.mulDiv(amount0, FixedPoint128.Q128, state.liquidity);
                    }
                    // 如果 amount1 大于 0，捐赠 token1 到流动性
                    if (amount1 > 0) {
                        state.feeGrowthGlobal1X128 += FullMath.mulDiv(amount1, FixedPoint128.Q128, state.liquidity);
                    }
                }
            }
            ```
        - 总结
            函数 `donate` 用于捐赠 `token0` 和 `token1` 到流动性。

### 设置协议手续费
- 内部函数（仅合约内部可以调用）
    - setProtocolFees
        - 代码解析
            ``` javascript
            function setProtocolFees(
                State storage self, 
                uint8 newProtocolSwapFee, // 新的协议 swap 费用
                uint8 newProtocolWithdrawFee // 新的协议提取流动性费用
            ) internal {
                // 不能是未创建过的 pool
                if (self.slot0.sqrtPriceX96 == 0) revert PoolNotInitialized();
                // 设置新的协议 swap 费用
                self.slot0.protocolSwapFee = newProtocolSwapFee;
                // 设置新的协议提取流动性费用
                self.slot0.protocolWithdrawFee = newProtocolWithdrawFee;
            }
            ```
        - 总结
            函数 `setProtocolFees` 用于设置协议手续费。

### 设置 hook 手续费
- 内部函数（仅合约内部可以调用）
    - setHookFees
        - 代码解析
            ``` javascript
            function setHookFees(
                State storage self, 
                uint8 newHookSwapFee, // 新的 hook swap 费用
                uint8 newHookWithdrawFee // 新的 hook 提取流动性费用
            ) internal {
                // 不能是未创建过的 pool
                if (self.slot0.sqrtPriceX96 == 0) revert PoolNotInitialized();
                // 设置新的 hook swap 费用
                self.slot0.hookSwapFee = newHookSwapFee;
                // 设置新的 hook 提取流动性费用
                self.slot0.hookWithdrawFee = newHookWithdrawFee;
            }
            ```
        - 总结
            函数 `setHookFees` 用于设置 hook 手续费。