# Uniswap-v2 Pair合约分析

Pair 合约是 Uniswap-v2 的资金池的合约，通过分析它可以深入了解 Uniswap-v2 资金池的运行逻辑。

演示代码仓库：[https://github.com/33357/uniswap-v2-contract](https://github.com/33357/uniswap-v2-contract)。

## 合约初始化
- 公共函数（合约内外部都可以调用）
    - constructor
        - 代码速览
            ``` javascript
            constructor() public {
                factory = msg.sender;
            }
            ```
        - 参数分析

            函数 `constructor` 的入参有0个，出参有0个。
            在合约初始化时，Pair 合约会将 `msg.sender` 记录为 `factory` 地址。
        - 实现分析
            ``` javascript
            ...
            {
                // 设置 factory 地址
                factory = msg.sender;
            }
            ```
        - 总结

            Pair 合约初始化时，会记录 `factory` 地址。
- 外部函数（仅合约外部可以调用）
    - initialize
        - 代码速览
            ``` javascript
            function initialize(address _token0, address _token1) external {
                require(msg.sender == factory, 'UniswapV2: FORBIDDEN');
                token0 = _token0;
                token1 = _token1;
            }
            ```
        - 参数分析

            函数 `initialize` 的入参有2个，出参有0个，对应的解释如下：
            ``` javascript
            function initialize(
                address _token0, // token0 地址
                address _token1 // token1 地址
            ) external {
                ...
            }
            ```
            由于 create2 函数无法传参，因此需要再次调用 `initialize` 函数来记录 `token0` 和 `token1` 的地址。
        - 实现分析
            ``` javascript
            ...
            {
                // 检查 msg.sender 地址等于 factory 地址
                require(msg.sender == factory, 'UniswapV2: FORBIDDEN');
                // 记录 token0 和 token1 地址
                token0 = _token0;
                token1 = _token1;
            }
            ```
        - 总结

            由于 `initialize` 是初始化函数，因此只能由 factory 调用，且只会调用一次。
## 资金池状态
- 公共函数（合约内外部都可以调用）
    - getReserves
        - 代码速览
            ``` javascript
            function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
                _reserve0 = reserve0;
                _reserve1 = reserve1;
                _blockTimestampLast = blockTimestampLast;
            }
            ```
        - 参数分析

            函数 `getReserves` 的入参有0个，出参有3个，对应的解释如下：
            ``` javascript
            function getReserves() public view returns (
                uint112 _reserve0, // token0 的资金池库存数量
                uint112 _reserve1, // token1 的资金池库存数量
                uint32 _blockTimestampLast // 上次更新库存的时间
            ) {
                ...
            }
            ```
            函数 `getReserves` 返回了 `_reserve0`、`_reserve1` 和 `_blockTimestampLast`，通过这些变量可以计算资产的价格。
        - 实现分析
            ``` javascript
            ...
            {
                // 返回 reserve0、reserve1 和 blockTimestampLast
                _reserve0 = reserve0;
                _reserve1 = reserve1;
                _blockTimestampLast = blockTimestampLast;
            }
            ```
        - 总结

            方便获取当前资金池状态。
## 更新资金池
- 内部函数（仅合约内部可以调用）
    - _update
        - 代码速览
            ``` javascript
            function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
                require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
                uint32 blockTimestamp = uint32(block.timestamp % 2**32);
                uint32 timeElapsed = blockTimestamp - blockTimestampLast;
                if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
                    price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
                    price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
                }
                reserve0 = uint112(balance0);
                reserve1 = uint112(balance1);
                blockTimestampLast = blockTimestamp;
                emit Sync(reserve0, reserve1);
            }
            ```
        - 参数分析

            函数 `_update` 的入参有4个，出参有0个，对应的解释如下：
            ``` javascript
            function _update(
                uint balance0, // token0 的余额
                uint balance1, // token1 的余额
                uint112 _reserve0, // token0 的资金池库存数量
                uint112 _reserve1 // token1 的资金池库存数量
            ) private {
                ...
            }
            ```
            函数 `_update` 的主要作用是对资金池的记录库存和实际余额进行匹配，保证库存和余额统一。
        - 实现分析
            ``` javascript
            ...
            {
                // 需要 balance0 和 blanace1 不超过 uint112 的上限
                require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
                // blockTimestamp 只取最后 32 位
                uint32 blockTimestamp = uint32(block.timestamp % 2**32);
                // 计算时间差 timeElapsed
                uint32 timeElapsed = blockTimestamp - blockTimestampLast;
                // 如果 timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0
                if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
                    // 对 _reserve1 / _reserve0 * timeElapsed 的结果在 price0CumulativeLast 上累加
                    price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
                    // 对 _reserve0 / _reserve1 * timeElapsed 的结果在 price1CumulativeLast 上累加
                    price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
                }
                // reserve0 = balance0
                reserve0 = uint112(balance0);
                // reserve1 = balance1
                reserve1 = uint112(balance1);
                // blockTimestampLast = blockTimestamp
                blockTimestampLast = blockTimestamp;
                // 触发事件 Sync
                emit Sync(reserve0, reserve1);
            }
            ```
        - 总结

            函数 `_update` 中对 `price0CumulativeLast` 和 `price1CumulativeLast` 进行了与时间成反比的数值累加，可以通过这两个变量计算出相对平衡的市场价格。
## 手续费
- 内部函数（仅合约内部可以调用）
    - _mintFee
        - 代码速览
            ``` javascript
            function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
                address feeTo = IUniswapV2Factory(factory).feeTo();
                feeOn = feeTo != address(0);
                uint _kLast = kLast;
                if (feeOn) {
                    if (_kLast != 0) {
                        uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                        uint rootKLast = Math.sqrt(_kLast);
                        if (rootK > rootKLast) {
                            uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                            uint denominator = rootK.mul(5).add(rootKLast);
                            uint liquidity = numerator / denominator;
                            if (liquidity > 0) _mint(feeTo, liquidity);
                        }
                    }
                } else if (_kLast != 0) {
                    kLast = 0;
                }
            }
            ```
        - 参数分析

            函数 `_mintFee` 的入参有2个，出参有1个，对应的解释如下：
            ``` javascript
            function _mintFee(
                uint112 _reserve0, // token0 的资金池库存数量
                uint112 _reserve1 // token1 的资金池库存数量
            ) private returns (
                bool feeOn // 是否开启手续费
            ) {
                ...
            }
            ```
            函数 `_mintFee` 实现了添加和移除流动性时，向 `feeTo` 地址发送手续费的逻辑。
        - 实现分析
            ``` javascript
            ...
            {
                // 获取手续费接收地址 feeTo
                address feeTo = IUniswapV2Factory(factory).feeTo();
                // 如果 feeTo 不是全0地址，那么 feeOn = true
                feeOn = feeTo != address(0);
                // 获取 kLast
                uint _kLast = kLast;
                // 如果 feeOn == true
                if (feeOn) {
                    // 如果 _kLast != 0
                    if (_kLast != 0) {
                        // rootK = (_reserve0*_reserve1)**2
                        uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                        // rootKLast = _kLast**2
                        uint rootKLast = Math.sqrt(_kLast);
                        // 如果 rootK > rootKLast
                        if (rootK > rootKLast) {
                            // 这里计算逻辑不是很清楚，希望有知道的补充一下
                            uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                            uint denominator = rootK.mul(5).add(rootKLast);
                            uint liquidity = numerator / denominator;
                            // 向 feeTo 地址增发数量为 liquidity 的 LP
                            if (liquidity > 0) _mint(feeTo, liquidity);
                        }
                    }
                } else if (_kLast != 0) {
                    // 如果 _kLast != 0，kLast = 0
                    kLast = 0;
                }
            }
            ```
        - 总结

            虽然在这里实现了向 `feeTo` 地址发送手续费，但是直到现在（2022年3月2日），`feeTo` 地址都是全0地址，也就是说没有收取任何手续费。
## 提供流动性
- 外部函数（仅合约外部可以调用）
    - burn
        - 代码速览
            ``` javascript
            function mint(address to) external lock returns (uint liquidity) {
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                uint balance0 = IERC20(token0).balanceOf(address(this));
                uint balance1 = IERC20(token1).balanceOf(address(this));
                uint amount0 = balance0.sub(_reserve0);
                uint amount1 = balance1.sub(_reserve1);
                bool feeOn = _mintFee(_reserve0, _reserve1);
                uint _totalSupply = totalSupply;
                if (_totalSupply == 0) {
                    liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
                _mint(address(0), MINIMUM_LIQUIDITY);
                } else {
                    liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
                }
                require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
                _mint(to, liquidity);
                _update(balance0, balance1, _reserve0, _reserve1);
                if (feeOn) kLast = uint(reserve0).mul(reserve1);
                emit Mint(msg.sender, amount0, amount1);
            }
            ```
        - 参数分析
            函数 `mint` 的入参有1个，出参有1个，对应的解释如下：
            ``` javascript
            function mint(
                address to // LP 接收地址
            ) external lock returns (
                uint liquidity // LP 数量
            ) {
                ...
            }
            ```
            函数 `mint` 的主要作用是用户存入流动性代币，提取 LP。流动性代币在调用 `mint` 之前就已经存入了资金池，因此需要计算存入代币数量。
        - 实现分析
            ``` javascript
            ...
            {
                // 获取记录库存 _reserve0，_reserve1
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                // 获取代币余额 balance0，balance1
                uint balance0 = IERC20(token0).balanceOf(address(this));
                uint balance1 = IERC20(token1).balanceOf(address(this));
                // 获取用户质押余额 amount0，amount1
                uint amount0 = balance0.sub(_reserve0);
                uint amount1 = balance1.sub(_reserve1);
                // 发送手续费
                bool feeOn = _mintFee(_reserve0, _reserve1);
                uint _totalSupply = totalSupply;
                // 如果 _totalSupply == 0
                if (_totalSupply == 0) {
                    // LP 代币数量 liquidity = (amount0 * amount1)**2 - MINIMUM_LIQUIDITY
                    liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
                    // 向全0地址发送数量为 MINIMUM_LIQUIDITY 的 LP 代币
                    _mint(address(0), MINIMUM_LIQUIDITY);
                } else {
                    // LP 代币数量 liquidity = min(_totalSupply * amount0 / _reserve0, _totalSupply * amount1 / _reserve1)
                    liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
                }
                // 需要 liquidity > 0
                require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
                // 向 to 地址发送数量为 liquidity
                _mint(to, liquidity);
                // 更新库存
                _update(balance0, balance1, _reserve0, _reserve1);
                // 如果 feeOn == true，更新 kLast
                if (feeOn) kLast = uint(reserve0).mul(reserve1);
                // 触发事件 Mint
                emit Mint(msg.sender, amount0, amount1);
            }
            ```
        - 总结

            为了避免创建流动性的数值太小引发计算错误，创建流动性需要大于 `MINIMUM_LIQUIDITY`。
## 移除流动性
- 外部函数（仅合约外部可以调用）
    - burn
        - 代码速览
            ``` javascript
            function burn(address to) external lock returns (uint amount0, uint amount1) {
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                address _token0 = token0;
                address _token1 = token1;
                uint balance0 = IERC20(_token0).balanceOf(address(this));
                uint balance1 = IERC20(_token1).balanceOf(address(this));
                uint liquidity = balanceOf[address(this)];
                bool feeOn = _mintFee(_reserve0, _reserve1);
                uint _totalSupply = totalSupply;
                amount0 = liquidity.mul(balance0) / _totalSupply;
                amount1 = liquidity.mul(balance1) / _totalSupply;
                require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
                _burn(address(this), liquidity);
                _safeTransfer(_token0, to, amount0);
                _safeTransfer(_token1, to, amount1);
                balance0 = IERC20(_token0).balanceOf(address(this));
                balance1 = IERC20(_token1).balanceOf(address(this));
                _update(balance0, balance1, _reserve0, _reserve1);
                if (feeOn) kLast = uint(reserve0).mul(reserve1);
                emit Burn(msg.sender, amount0, amount1, to);
            }
            ```
        - 参数分析
            函数 `burn` 的入参有1个，出参有2个，对应的解释如下：
            ``` javascript
            function burn(
                address to // 资产接收地址
            ) external lock returns (
                uint amount0, // 获得的 token0 数量
                uint amount1 // 获得的 token1 数量
            ) {
                ...
            }
            ```
            函数 `burn` 的主要作用是用户销毁 LP，从资金池提取流动性代币。同样在调用 `burn` 之前，LP 已经发送给资金池，资金池中 LP 余额就是需要销毁的 LP 数量。
        - 实现分析
            ``` javascript
            ...
            {
                // 获取记录库存 _reserve0，_reserve1
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                // 获取 _token0，_token1
                address _token0 = token0;
                address _token1 = token1;
                // 获取代币余额 balance0，balance1
                uint balance0 = IERC20(_token0).balanceOf(address(this));
                uint balance1 = IERC20(_token1).balanceOf(address(this));
                // 获取 liquidity
                uint liquidity = balanceOf[address(this)];
                // 发送手续费
                bool feeOn = _mintFee(_reserve0, _reserve1);
                uint _totalSupply = totalSupply;
                // amount0 = liquidity * balance0 / _totalSupply
                amount0 = liquidity.mul(balance0) / _totalSupply;
                // amount1 = liquidity * balance1 / _totalSupply
                amount1 = liquidity.mul(balance1) / _totalSupply;
                // 需要 amount0 > 0 && amount1 > 0
                require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
                // 销毁 liquidity 数量的 LP代币
                _burn(address(this), liquidity);
                // 将 amount0 数量的 _token0 发送到 to 地址
                _safeTransfer(_token0, to, amount0);
                // 将 amount1 数量的 _token1 发送到 to 地址
                _safeTransfer(_token1, to, amount1);
                // 重新获取 balance0 和 balance1
                balance0 = IERC20(_token0).balanceOf(address(this));
                balance1 = IERC20(_token1).balanceOf(address(this));
                // 更新库存
                _update(balance0, balance1, _reserve0, _reserve1);
                // 如果 feeOn == true，更新 kLast
                if (feeOn) kLast = uint(reserve0).mul(reserve1);
                // 触发事件 Burn
                emit Burn(msg.sender, amount0, amount1, to);
            }
            ```
        - 总结

            如果有人向资金池发送 LP，那么实际上并没有销毁该 LP，而是送给了下一个销毁 LP 的人。因为虽然没人能提取出来，但任何人都可以销毁该 LP 并获得相应的流动性代币。
## 交易
- 外部函数（仅合约外部可以调用）
    - swap
        - 代码速览
            ``` javascript
            function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
                require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');
                uint balance0;
                uint balance1;
                {
                    address _token0 = token0;
                    address _token1 = token1;
                    require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
                    if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
                    if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
                    if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
                    balance0 = IERC20(_token0).balanceOf(address(this));
                    balance1 = IERC20(_token1).balanceOf(address(this));
                }
                uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
                uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
                require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
                {
                    uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
                    uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
                    require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
                }
                _update(balance0, balance1, _reserve0, _reserve1);
                emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
            }
            ```
        - 参数分析
            函数 `swap` 的入参有4个，出参有0个，对应的解释如下：
            ``` javascript
            function swap(
                uint amount0Out, // 预期获得的 token0 数量
                uint amount1Out, // 预期获得的 token1 数量
                address to, // 资产接收地址
                bytes calldata data // 闪电贷调用数据
            ) external lock {
                ...
            }
            ```
            函数 `swap` 的主要功能是执行代币交换，并支持了闪电贷的功能。
        - 实现分析
            ``` javascript
            ...
            {
                // 需要 amount0Out > 0 || amount1Out > 0
                require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
                // 获取记录库存 _reserve0，_reserve1
                (uint112 _reserve0, uint112 _reserve1,) = getReserves();
                // 需要 amount0Out < _reserve0 && amount1Out < _reserve1
                require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');
                uint balance0;
                uint balance1;
                {
                    address _token0 = token0;
                    address _token1 = token1;
                    // 需要 to 地址不是 token0 地址和 token1 地址
                    require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
                    // 如果 amount0Out > 0，向 to 地址发送数量为 amount0Out 的 _token0 代币
                    if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
                    // 如果 amount1Out > 0，向 to 地址发送数量为 amount1Out 的 _token1 代币
                    if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
                    // 如果 data.length > 0，执行闪电贷
                    if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
                    // 获取 _token0 余额 balance0
                    balance0 = IERC20(_token0).balanceOf(address(this));
                    // 获取 _token1 余额 balance1
                    balance1 = IERC20(_token1).balanceOf(address(this));
                }
                // 如果 balance0 > _reserve0 - amount0Out，需要支付的 token0 数量 amount0In = balance0 - (_reserve0 - amount0Out)，否则为0
                uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
                // 如果 balance1 > _reserve1 - amount1Out，需要支付的 token1 数量 amount1In = balance1 - (_reserve1 - amount1Out)，否则为0
                uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
                // 需要 amount0In > 0 || amount1In > 0
                require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
                {
                    // 需要交易之后的 K 值不能变小
                    uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
                    uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
                    require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
                }
                // 更新库存
                _update(balance0, balance1, _reserve0, _reserve1);
                // 触发 Swap 事件
                emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
            }
            ```
        - 总结

            比较巧妙的一点是，`swap` 没有在交易之前进行数量计算，取而代之的是在交易完成之后进行检查。这减少了区块链上的计算量，并很好地支持了闪电贷功能。
## 再平衡
- 外部函数（仅合约外部可以调用）
    - skim
        - 代码速览
            ``` javascript
            function skim(address to) external lock {
                address _token0 = token0;
                address _token1 = token1;
                _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
                _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
            }
            ```
        - 参数分析
            函数 `skim` 的入参有1个，出参有0个，对应的解释如下：
            ``` javascript
            function skim(
                address to // 资产接收地址
            ) external lock {
                ...
            }
            ```
            函数 `skim` 可以让调用者获得多于库存的代币。
        - 实现分析
            ``` javascript
            ...
            {
                address _token0 = token0;
                address _token1 = token1;
                // 将多于库存 reserve0 的代币 _token0 发送到 to 地址
                _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
                // 将多于库存 reserve1 的代币 _token1 发送到 to 地址
                _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
            }
            ```
        - 总结

            任何人都可以调用这个函数获取多于库存的代币。
    - skim
        - 代码速览
            ``` javascript
            function sync() external lock {
                _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
            }
            ```
        - 参数分析
            函数 `sync` 的入参有0个，出参有0个。
            函数 `sync` 用于强制匹配库存和代币余额。
        - 实现分析
            ``` javascript
            ...
            {
                // 更新库存
                _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
            }
            ```
        - 总结

            任何人都可以调用这个函数强制更新库存。