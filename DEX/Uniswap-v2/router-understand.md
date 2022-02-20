# Uniswap-v2 Router合约分析

Router 合约是用户使用 Uniswap-v2 进行交换直接调用的合约，通过分析它可以深入了解 Uniswap-v2 的产品使用和运行逻辑。

演示代码仓库：[https://github.com/33357/uniswap-v2-contract](https://github.com/33357/uniswap-v2-contract)，这里使用的是Router02。

# 增加流动性

- 内部函数（仅供合约内部调用）
    - _addLiquidity
        - 代码速浏览
            ``` javascript
            function _addLiquidity(
                address tokenA,
                address tokenB,
                uint amountADesired,
                uint amountBDesired,
                uint amountAMin,
                uint amountBMin
            ) internal virtual returns (uint amountA, uint amountB) {
                if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
                    IUniswapV2Factory(factory).createPair(tokenA, tokenB);
                }
                (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
                if (reserveA == 0 && reserveB == 0) {
                    (amountA, amountB) = (amountADesired, amountBDesired);
                } else {
                    uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
                    if (amountBOptimal <= amountBDesired) {
                        require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
                        (amountA, amountB) = (amountADesired, amountBOptimal);
                    } else {
                        uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                        assert(amountAOptimal <= amountADesired);
                        require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                        (amountA, amountB) = (amountAOptimal, amountBDesired);
                    }
                }
            }
            ```
        - 参数分析

            函数 `_addLiquidity` 的入参有6个，出参有2个，对应的解释如下：
            ``` javascript
            function _addLiquidity(
                address tokenA, // 添加流动性 tokenA 的地址
                address tokenB, // 添加流动性 tokenB 的地址
                uint amountADesired, // 期望添加 tokenA 的数量
                uint amountBDesired, // 期望添加 tokenB 的数量
                uint amountAMin, // 添加 tokenA 的最小数量
                uint amountBMin // 添加 tokenB 的最小数量
            ) internal virtual returns (
                uint amountA, // 实际添加 tokenA 的数量
                uint amountB // 实际添加 tokenB 的数量
                ) {
                    ...
            }
            ```
            `tokenA` 和 `tokenB` 很好理解，但是为什么要有 `amountADesired`、`amountADesired`、`amountAMin`、`amountBMin` 呢？实际上因为用户在区块链上添加流动性并不是实时完成的，因此会因为其他用户的操作产生数据偏差，因此需要在这里指定一个为 `tokenA` 和 `tokenB` 添加流动性的数值范围。在添加流动性的过程中，首先会根据 `amountADesired` 计算出实际要添加的 `amountB`，如果 `amountB` 大于 `amountBDesired` 就换成根据 `amountBDesired` 计算出实际要添加的 `amountA`。
        - 实现分析
            ``` javascript
            ...
            {
                // 如果 tokenA,tokenB 的流动池不存在，就创建流动池
                if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
                    IUniswapV2Factory(factory).createPair(tokenA, tokenB);
                }
                // 获取 tokenA,tokenB 的目前库存数量
                (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
                if (reserveA == 0 && reserveB == 0) {
                    // 如果库存数量为0，也就是新建 tokenA,tokenB 的流动池，那么实际添加的amountA, amountB 就是 amountADesired 和 amountBDesired
                    (amountA, amountB) = (amountADesired, amountBDesired);
                } else {
                    // reserveA*reserveB/amountADesired，算出实际要添加的 tokenB 数量 amountBOptimal
                    uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
                    if (amountBOptimal <= amountBDesired) {
                        // 如果 amountBMin <= amountBOptimal <= amountBDesired，amountA 和 amountB 就是 amountADesired 和 amountBOptimal
                        require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
                        (amountA, amountB) = (amountADesired, amountBOptimal);
                    } else {
                        // reserveA*reserveB/amountBDesired，算出实际要添加的 tokenA 数量 amountAOptimal
                        uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                        // 如果 amountAMin <= amountAOptimal <= amountADesired，amountA 和 amountB 就是 amountAOptimal 和 amountBDesired
                        assert(amountAOptimal <= amountADesired);
                        require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                        (amountA, amountB) = (amountAOptimal, amountBDesired);
                    }
                }
            }
            ```
        - 总结

            在实际上，计算出来的 `mountA` 和 `mountB` 只需要满足这个公式：`(amountAMin = mountA && amountBMin <= mountB <= amountBDesired) || (amountAMin <= mountA <= amountADesired && mountB = amountBDesired)`。

- 外部函数（仅供合约外部调用）
    - addLiquidity
        - 代码速浏览
            ``` javascript
            function addLiquidity(
                address tokenA,
                address tokenB,
                uint amountADesired,
                uint amountBDesired,
                uint amountAMin,
                uint amountBMin,
                address to,
                uint deadline
            ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
                (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
                TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
                liquidity = IUniswapV2Pair(pair).mint(to);
            }
            ```
        - 参数分析

            函数 `addLiquidity` 的入参有8个，出参有3个，对应的解释如下：
            ``` javascript
            function addLiquidity(
                address tokenA, // 添加流动性 tokenA 的地址
                address tokenB, // 添加流动性 tokenB 的地址
                uint amountADesired, // 期望添加 tokenA 的数量
                uint amountBDesired, // 期望添加 tokenB 的数量
                uint amountAMin, // 添加 tokenA 的最小数量
                uint amountBMin // 添加 tokenB 的最小数量
                address to, // 获得的 LP 发送到的地址
                uint deadline // 过期时间
            ) external virtual override ensure(deadline) returns (
                uint amountA, // 实际添加 tokenA 的数量
                uint amountB // 实际添加 tokenB 的数量
                uint liquidity // 获得 LP 的数量
                ) {
                ...
            }
            ```
            相比于内部函数 `_addLiquidity`，`addLiquidity` 函数的入参多了 `to` 和  `deadline`，`to` 可以指定 LP（流动性凭证）发送到哪个地址，而 `deadline` 则设置交易过期时间。出参则多了一个 `liquidity`，指 LP 的数量。
        - 实现分析
            ``` javascript
            ... 
            // 检查交易是否过期
            ensure(deadline){
                // 计算实际添加的 amountA, amountB
                (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
                // 获取 tokenA, tokenB 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                // 用户向流动池发送数量为 amountA 的 tokenA，amountB 的 tokenB
                TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
                TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
                // 流动池向 to 地址发送数量为 liquidity 的 LP
                liquidity = IUniswapV2Pair(pair).mint(to);
            }
            ```
        - 总结

            外部函数 `addLiquidity` 实现了用户添加 `ERC20` 交易对流动性的操作。值得注意的是，设置 `to` 实际上方便了第三方合约添加流动性，这为后来聚合交易所的出现，埋下了伏笔。
    - addLiquidityETH
        - 代码速浏览
            ``` javascript
            function addLiquidityETH(
                address token,
                uint amountTokenDesired,
                uint amountTokenMin,
                uint amountETHMin,
                address to,
                uint deadline
            ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
                (amountToken, amountETH) = _addLiquidity(
                    token,
                    WETH,
                    amountTokenDesired,
                    msg.value,
                    amountTokenMin,
                    amountETHMin
                );
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
                IWETH(WETH).deposit{value: amountETH}();
                assert(IWETH(WETH).transfer(pair, amountETH));
                liquidity = IUniswapV2Pair(pair).mint(to);
                if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
            }
            ```
        - 参数分析

            函数 `addLiquidityETH` 的入参有6个，出参有3个，对应的解释如下：
            ``` javascript
             function addLiquidityETH(
                address token, // 添加流动性 token 的地址
                uint amountTokenDesired, // 期望添加 token 的数量
                uint amountTokenMin, // 添加 token 的最小数量
                uint amountETHMin, // 添加 ETH 的最小数量
                address to, // 获得的 LP 发送到的地址
                uint deadline // 过期时间
            ) external virtual override payable ensure(deadline) returns (
                uint amountToken, // 实际添加 token 的数量
                uint amountETH, // 实际添加 ETH 的数量
                uint liquidity // 获得 LP 的数量
            ) {
                ...
            }
            ```
            相比于`addLiquidity`，`addLiquidityETH` 函数的不同之处在于使用了 ETH 作为 tokenB，因此不需要指定 tokenB 的地址和期望数量，因为 tokenB 的地址就是 WETH 的地址，tokenB 的期望数量就是用户发送的 ETH 数量。但这样也多了将 ETH 换成 WETH，并向用户返还多余 ETH 的操作。
        - 实现分析
            ``` javascript
            ... 
            // 检查交易是否过期
            ensure(deadline){
                // 计算实际添加的 amountToken, amountETH
                (amountToken, amountETH) = _addLiquidity(
                    token,
                    WETH,
                    amountTokenDesired,
                    msg.value,
                    amountTokenMin,
                    amountETHMin
                );
                // 获取 token, WETH 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                // 向用户向流动池发送数量为 amountToken 的 token
                TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
                // Router将用户发送的 ETH 置换成 WETH
                IWETH(WETH).deposit{value: amountETH}();
                // Router向流动池发送数量为 amountETH 的 WETH
                assert(IWETH(WETH).transfer(pair, amountETH));
                // 流动池向 to 地址发送数量为 liquidity 的 LP
                liquidity = IUniswapV2Pair(pair).mint(to);
                // 如果用户发送的 ETH > amountETH，Router就向用户返还多余的 ETH
                if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
            }
            ```
        - 总结
            
            由于 ETH 本身不是 ERC20 标准的代币，因此在涉及添加 ETH 流动性的操作时要把它换成兼容 ERC20 接口 WETH。

# 移除流动性

- 公共函数（合约内外部都可以调用）
    - removeLiquidity
        - 代码速浏览
            ``` javascript
            function removeLiquidity(
                address tokenA,
                address tokenB,
                uint liquidity,
                uint amountAMin,
                uint amountBMin,
                address to,
                uint deadline
            ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
                (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
                (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
                (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
                require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
            }
            ```
        - 参数分析

            函数`removeLiquidity`的入参有7个，出参有2个，对应的解释如下：
            ``` javascript
            function removeLiquidity(
                address tokenA, // 移除流动性 tokenA 的地址
                address tokenB, // 移除流动性 tokenB 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountAMin, // 获得 tokenA 数量的最小值
                uint amountBMin, // 获得 tokenB 数量的最小值
                address to, // 获得的 tokenA、tokenB 发送到的地址
                uint deadline // 过期时间
            ) public virtual override ensure(deadline) returns (
                uint amountA, // 实际获得 tokenA 的数量
                uint amountB // 实际获得 tokenB 的数量
                ) {
                ...
            }
            ```
            用户在移除流动性时，需要销毁 LP 换回 `tokenA` 和 `tokenB`。由于操作不是实时的，因此同样需要指定 `amountAMin` 和 `amountBMin`，如果实际获得的 `amountA` 小于 `amountAMin` 或者 `amountB` 小于 `amountBMin`，那么移除流动性的操作都会失败。
         - 实现分析
            ``` javascript
            ... 
            // 检查交易是否过期
            ensure(deadline) {
                // 获取 token, WETH 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                // 用户向流动池发送数量为 liquidity 的 LP
                IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
                // 流动池销毁 LP 并向 to 地址发送数量为 amount0 的 token0 和 amount1 的 token1
                (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
                // 计算出 tokenA, tokenB 中谁是 token0,token1
                (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
                // 如果实际获得的 amountA < amountAMin 或者 amountB < amountBMin，那么交易失败
                (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
                require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
            }
            ```
        - 总结

            移除流动性并不会检查你是否是流动性的添加者，只要你拥有 LP，那么就拥有了流动性的所有权。因此一定要保管好自己的 LP（本人真金白银的教训）。
    - removeLiquidityETH
        - 代码速浏览
            ``` javascript
            function removeLiquidityETH(
                address token,
                uint liquidity,
                uint amountTokenMin,
                uint amountETHMin,
                address to,
                uint deadline
            ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
                (amountToken, amountETH) = removeLiquidity(
                    token,
                    WETH,
                    liquidity,
                    amountTokenMin,
                    amountETHMin,
                    address(this),
                    deadline
                );
                TransferHelper.safeTransfer(token, to, amountToken);
                IWETH(WETH).withdraw(amountETH);
                TransferHelper.safeTransferETH(to, amountETH);
            }
            ```
        - 参数分析

            函数`removeLiquidityETH`的入参有6个，出参有2个，对应的解释如下：
            ``` javascript
            function removeLiquidityETH(
                address token, // 移除流动性 token 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountTokenMin, // 获得 token 数量的最小值
                uint amountETHMin, // 获得 ETH 数量的最小值
                address to, // 获得的 token、ETH 发送到的地址
                uint deadline // 过期时间
            ) public virtual override ensure(deadline) returns (
                uint amountToken, // 实际获得 token 的数量
                uint amountETH // 实际获得 ETH 的数量
            ) {
                ...
            }
            ```
            因为移除流动性的是 ETH，因此不需要传入 ETH 的地址，改为使用 WETH。
         - 实现分析
            ``` javascript
            ... 
            // 检查交易是否过期
            ensure(deadline) {
                // 移除流动性，Router获得数量为 amountToken 的 token，amountETH 的 WETH
                (amountToken, amountETH) = removeLiquidity(
                    token,
                    WETH,
                    liquidity,
                    amountTokenMin,
                    amountETHMin,
                    address(this),
                    deadline
                );
                // 向 to 地址发送数量为 amountToken 的 token
                TransferHelper.safeTransfer(token, to, amountToken);
                // 将数量为 amountETH 的 WETH 换成 ETH
                IWETH(WETH).withdraw(amountETH);
                // 向 to 地址发送数量为 amountToken 的 ETH
                TransferHelper.safeTransferETH(to, amountETH);
            }
            ```
        - 总结

            因为流动池中质押的是 WETH，因此在移除流动性时需要把 WETH 换回 ETH。
- 外部函数（仅供合约外部调用）

    - removeLiquidityWithPermit
        - 代码速浏览
            ``` javascript
            function removeLiquidityWithPermit(
                address tokenA,
                address tokenB,
                uint liquidity,
                uint amountAMin,
                uint amountBMin,
                address to,
                uint deadline,
                bool approveMax, uint8 v, bytes32 r, bytes32 s
            ) external virtual override returns (uint amountA, uint amountB) {
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                uint value = approveMax ? uint(-1) : liquidity;
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
            }
            ```
        - 参数分析

            函数 `removeLiquidityWithPermit` 的入参有11个，出参有2个，对应的解释如下：
            ``` javascript
            function removeLiquidityWithPermit(
                address tokenA, // 移除流动性 tokenA 的地址
                address tokenB, // 移除流动性 tokenB 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountAMin, // 获得 tokenA 数量的最小值
                uint amountBMin, // 获得 tokenB 数量的最小值
                address to, // 获得的 tokenA、tokenB 发送到的地址
                uint deadline, // 过期时间
                bool approveMax, // 是否授权为最大值
                uint8 v, bytes32 r, bytes32 s // 签名 v,r,s
            ) external virtual override returns (
                uint amountA, // 实际获得 tokenA 的数量
                uint amountB // 实际获得 tokenB 的数量
                ) {
                ...
            }
            ```
            函数 `removeLiquidityWithPermit` 这个实现了签名授权 Router 使用用户的 LP。首先要明确的是，合约调用用户的代币需要用户的授权才能进行，而 LP 的授权既可以发送一笔交易，也可以使用签名。而使用 `removeLiquidityWithPermit` 可以让用户免于发送一笔授权交易，转而使用签名，从而简化用户的操作。
         - 实现分析
            ``` javascript
            ... 
            {
                // 获取 tokenA, tokenB 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
                // 获取授权 LP 的数量
                uint value = approveMax ? uint(-1) : liquidity;
                // 授权 Router 使用用户数量为 value 的 LP
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                // 移除流动性
                (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
            }
            ```
        - 总结

            使用签名进行授权，简化了用户的操作，但有些人可能会利用用户对签名的不了解，盗窃用户资产。

    - removeLiquidityETHWithPermit

        - 代码速浏览
            ``` javascript
            function removeLiquidityETHWithPermit(
                address token,
                uint liquidity,
                uint amountTokenMin,
                uint amountETHMin,
                address to,
                uint deadline,
                bool approveMax, uint8 v, bytes32 r, bytes32 s
            ) external virtual override returns (uint amountToken, uint amountETH) {
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                uint value = approveMax ? uint(-1) : liquidity;
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
            }
            ```
        - 参数分析

            函数`removeLiquidityETHWithPermit`的入参有10个，出参有2个，对应的解释如下：
            ``` javascript
             function removeLiquidityETHWithPermit(
                address token, // 移除流动性 token 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountTokenMin, // 获得 token 数量的最小值
                uint amountETHMin, // 获得 ETH 数量的最小值
                address to, // 获得的 token、ETH 发送到的地址
                uint deadline, // 过期时间
                bool approveMax,  // 是否授权为最大值
                uint8 v, bytes32 r, bytes32 s // 签名 v,r,s
            ) external virtual override returns (
                uint amountToken, // 实际获得 token 的数量
                uint amountETH // 实际获得 ETH 的数量
                ){
                ...
            }
            ```
            因为移除流动性的是 ETH，因此不需要传入 ETH 的地址，改为使用 WETH。
         - 实现分析
            ``` javascript
            ... 
            {
                // 获取 tokenA, WETH 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                // 获取授权 LP 的数量
                uint value = approveMax ? uint(-1) : liquidity;
                // 授权 Router 使用用户数量为 value 的 LP
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                 // 移除 ETH 流动性
                (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
            }
            ```
        - 总结

            无
# 移除流动性（支持代付GAS代币）
- 公共函数（合约内外部都可以调用）
    - removeLiquidityETHSupportingFeeOnTransferTokens
        - 代码速浏览
            ``` javascript
            function removeLiquidityETHSupportingFeeOnTransferTokens(
                address token,
                uint liquidity,
                uint amountTokenMin,
                uint amountETHMin,
                address to,
                uint deadline
            ) public virtual override ensure(deadline) returns (uint amountETH) {
                (, amountETH) = removeLiquidity(
                    token,
                    WETH,
                    liquidity,
                    amountTokenMin,
                    amountETHMin,
                    address(this),
                    deadline
                );
                TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
                IWETH(WETH).withdraw(amountETH);
                TransferHelper.safeTransferETH(to, amountETH);
            }
            ```
        - 参数分析

            函数`removeLiquidityETHSupportingFeeOnTransferTokens`的入参有6个，出参有1个，对应的解释如下：
            ``` javascript
            function removeLiquidityETHSupportingFeeOnTransferTokens(
                address token, // 移除流动性 token 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountTokenMin, // 获得 token 数量的最小值
                uint amountETHMin, // 获得 ETH 数量的最小值
                address to, // 获得的 token、ETH 发送到的地址
                uint deadline // 过期时间
            ) public virtual override ensure(deadline) returns (
                uint amountETH // 实际获得 ETH 的数量
            ) {
                ...
            }
            ```
            从参数上看，相比于 `removeLiquidityETH`，`removeLiquidityETHSupportingFeeOnTransferTokens` 少了一个出参。这是因为函数 `removeLiquidityETHSupportingFeeOnTransferTokens` 的主要功能是支持第三方为用户支付手续费并收取一定的代币，因此 `amountToken` 中有一部分会被第三方收取，用户真实获取的代币数量会比 `amountToken` 少。具体见 [ERC865](https://github.com/ethereum/EIPs/issues/865)
        - 实现分析
            ``` javascript
            ... 
            // 检查交易是否过期
            ensure(deadline)
            {
            // 移除流动性，Router获得不定数量的 token，数量为 amountETH 的 WETH
                (, amountETH) = removeLiquidity(
                    token,
                    WETH,
                    liquidity,
                    amountTokenMin,
                    amountETHMin,
                    address(this),
                    deadline
                );
                // 向 to 地址发送全部 token
                TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
                // 将数量为 amountETH 的 WETH 换成 ETH
                IWETH(WETH).withdraw(amountETH);
                // 向 to 地址发送数量为 amountToken 的 ETH
                TransferHelper.safeTransferETH(to, amountETH);
            }
            ```
        - 总结

            实际上 `removeLiquidityETHSupportingFeeOnTransferTokens` 支持了所有在移除流动性时，数量会变化的代币，有一些代币的经济模式利用到了这点。
- 外部函数（仅供合约外部调用）
    - removeLiquidityETHWithPermitSupportingFeeOnTransferTokens
        - 代码速浏览
            ``` javascript
            function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
                address token,
                uint liquidity,
                uint amountTokenMin,
                uint amountETHMin,
                address to,
                uint deadline,
                bool approveMax, uint8 v, bytes32 r, bytes32 s
            ) external virtual override returns (uint amountETH) {
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                uint value = approveMax ? uint(-1) : liquidity;
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
                    token, liquidity, amountTokenMin, amountETHMin, to, deadline
                );
            }
            ```
        - 参数分析

            函数`removeLiquidityETHWithPermitSupportingFeeOnTransferTokens`的入参有10个，出参有1个，对应的解释如下：
            ``` javascript
            function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
                address token, // 移除流动性 token 的地址
                uint liquidity, // 销毁 LP 的数量
                uint amountTokenMin,  // 获得 token 数量的最小值
                uint amountETHMin,  // 获得 ETH 数量的最小值
                address to, // 获得的 token、ETH 发送到的地址
                uint deadline, // 过期时间
                bool approveMax, // 是否授权为最大值
                uint8 v, bytes32 r, bytes32 s // 签名 v,r,s
            ) external virtual override returns (
                uint amountETH // 实际获得 ETH 的数量
            ) {
                ...
            }
            ```
            `removeLiquidityETHWithPermitSupportingFeeOnTransferTokens`同样比 `removeLiquidityETHWithPermit` 少了一个出参，这同样是为了支持在移除流动性时，数量会变化的代币。
        - 实现分析
            ``` javascript
            ... 
            {
                // 获取 tokenA, WETH 的流动池地址
                address pair = UniswapV2Library.pairFor(factory, token, WETH);
                // 获取授权 LP 的数量
                uint value = approveMax ? uint(-1) : liquidity;
                // 授权 Router 使用用户数量为 value 的 LP
                IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
                // 移除流动性并获得不定数量的 token 和数量为 amountETH 的 ETH
                amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
                    token, liquidity, amountTokenMin, amountETHMin, to, deadline
                );
            }
            ```
        - 总结

            无

# 交易
