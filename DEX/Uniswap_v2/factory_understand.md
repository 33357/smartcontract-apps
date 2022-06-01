# Uniswap-v2 Factory合约分析

Factory 合约是 Uniswap-v2 用来创建资金池的合约，通过分析它可以深入了解 Uniswap-v2 工厂合约的运行逻辑。

演示代码仓库：[https://github.com/33357/uniswap-v2-contract](https://github.com/33357/uniswap-v2-contract)。

## 合约初始化
- 公共函数（合约内外部都可以调用）
    - constructor
        - 代码速览
            ``` javascript
            constructor(address _feeToSetter) public {
                feeToSetter = _feeToSetter;
            }
            ```
        - 参数分析

            函数 `constructor` 的入参有1个，出参有0个，对应的解释如下：
            ``` javascript
            constructor(
                address _feeToSetter // 手续费管理员地址
            ) public {
                ...
            }
            ```
            在合约初始化时，需要在函数 `constructor` 中传入 `_feeToSetter`，该参数设置了手续费管理员地址。
        - 实现分析
            ``` javascript
            ...
            {
                // 设置手续费管理员地址
                feeToSetter = _feeToSetter;
            }
            ```
        - 总结

            Factory 合约初始化时，需要传入手续费管理员地址。
## 资金池
- 外部函数（仅合约外部可以调用）
    - allPairsLength
        - 代码速览
            ``` javascript
            function allPairsLength() external view returns (uint) {
                return allPairs.length;
            }
            ```
        - 参数分析

            函数 `allPairsLength` 的入参有0个，出参有1个，对应的解释如下：
            ``` javascript
            function allPairsLength() external view returns (
                uint // 资金池的数量
            ) {
                ...
            }
            ```
            函数 `allPairsLength` 返回了 `allPairs` 的长度，也就是当前资金池的数量。
        - 实现分析
            ``` javascript
            ...
            {
                // 返回资金池数组的长度
                return allPairs.length;
            }
            ```
        - 总结

            获取 allPairs 需要输入 index，因此需要获取资金池数组。
    - createPair
        - 代码速览
            ``` javascript
            function createPair(address tokenA, address tokenB) external returns (address pair) {
                require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
                (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
                require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
                require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS');
                bytes memory bytecode = type(UniswapV2Pair).creationCode;
                bytes32 salt = keccak256(abi.encodePacked(token0, token1));
                assembly {
                    pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
                }
                IUniswapV2Pair(pair).initialize(token0, token1);
                getPair[token0][token1] = pair;
                getPair[token1][token0] = pair;
                allPairs.push(pair);
                emit PairCreated(token0, token1, pair, allPairs.length);
            }
            ```
        - 参数分析

            函数 `createPair` 的入参有2个，出参有1个，对应的解释如下：
            ``` javascript
            function createPair(
                address tokenA, // tokenA 的地址
                address tokenB // tokenB 的地址
            ) external returns (
                address pair // 资金池地址
            ) {
                ...
            }
            ```
            函数 `createPair` 可以创建新的资金池合约，需要传入 `tokenA` 和 `tokenB`，返回资金池地址 `pair`。
        - 实现分析
            ``` javascript
            ...
            {
                // 需要 tokenA 不等于 tokenB
                require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
                // 计算 tokenA 和 tokenB 中谁是 token0 和 token1
                (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
                // 需要 token0 不是全0地址
                require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
                // 需要 token0 和 token1 没有创建过资金池
                require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS');
                // 获取 UniswapV2Pair 合约的字节码
                bytes memory bytecode = type(UniswapV2Pair).creationCode;
                // 使用参数 token0, token1 计算 salt
                bytes32 salt = keccak256(abi.encodePacked(token0, token1));
                // 使用 create2 部署 Pair 合约
                assembly {
                    pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
                }
                // Pair 合约初始化
                IUniswapV2Pair(pair).initialize(token0, token1);
                // 记录 token0,token1 创建的资金池地址是 pair
                getPair[token0][token1] = pair;
                getPair[token1][token0] = pair;
                // pair 加入资金池数组
                allPairs.push(pair);
                // 触发资金池创建事件
                emit PairCreated(token0, token1, pair, allPairs.length);
            }
            ```
        - 总结

            `create2(0, add(bytecode, 32), mload(bytecode), salt)`中的四个参数意思分别是：创建合约发送的 ETH 数量、bytecode 起始位置、bytecode 长度、生成合约地址的随机盐值。
## 手续费

- 外部函数（仅合约外部可以调用）
    - setFeeTo
        - 代码速览
            ``` javascript
            function setFeeTo(address _feeTo) external {
                require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
                feeTo = _feeTo;
            }
            ```
        - 参数分析

            函数 `setFeeTo` 的入参有1个，出参有0个，对应的解释如下：
            ``` javascript
            function setFeeTo(
                address _feeTo // 手续费接收地址
            ) external {
                ...
            }
            ```
            函数 `setFeeTo` 可以设置手续费接收地址，但需要手续费管理员调用才能成功。
        - 实现分析
            ``` javascript
            ...
            {
                // 检查调用者是否是手续费管理员
                require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
                // 设置手续费接收地址
                feeTo = _feeTo;
            }
            ```
        - 总结

            只有手续费管理员才能设置手续费接收地址。
    - setFeeToSetter
        - 代码速览
            ``` javascript
            function setFeeToSetter(address _feeToSetter) external {
                require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
                feeToSetter = _feeToSetter;
            }
            ```
        - 参数分析

            函数 `setFeeToSetter` 的入参有1个，出参有0个，对应的解释如下：
            ``` javascript
            function setFeeToSetter(
               address _feeToSetter // 手续费管理员地址
            ) external {
                ...
            }
            ```
            函数 `setFeeToSetter` 可以设置手续费管理员地址，但需要手续费管理员调用才能成功。
        - 实现分析
            ``` javascript
            ...
            {
                // 检查调用者是否是手续费管理员
                require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
                 // 设置手续费管理员地址
                feeToSetter = _feeToSetter;
            }
            ```
        - 总结

            只有手续费管理员才能设置手续费管理员地址。

