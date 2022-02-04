# 使用官方项目部署 Uniswap-v2

## 获取测试代币

我们选择Rinkeby测试网络部署Uniswap-v2，首先需要获取测试代币。

- [官方的水龙头](https://faucet.rinkeby.io/)，需要在twitter发帖

- 这里推荐通过更加简单的 [chainlink水龙头](https://faucets.chain.link/rinkeby) 获取测试用代币。

## 使用 remix 部署合约

- 打开 [remix](https://remix.ethereum.org/) 官网。

- 部署WETH
  - 编译设置
    - 新建文件 WETH.sol，将 [WETH合约源码](https://cn.etherscan.com/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code) 复制过来。
    - 使用默认环境编译
  - 部署设置
    - CONTRACT 选择 WETH9，ENVIRONMENT 选择 Injected Web3
    - 连接 MetaMask 的 Rinkeby 网络进行部署。

- 部署Factory
  - 编译设置
    - 新建文件 UniswapV2Factory.sol，将 [Factor合约源码](https://cn.etherscan.com/address/0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f#code) 复制过来。
    - 使用默认环境编译
  - 部署设置
    - 随便设置一个 _feeToSetter 地址之后，CONTRACT 选择UniswapV2Factory，ENVIRONMENT 选择 Injected Web3
    - 连接 MetaMask 的 Rinkeby 网络进行部署。

- 部署Router
  - 编译设置
    - 新建文件 UniswapV2Router02.sol，将 [Router合约源码](https://cn.etherscan.com/address/0x7a250d5630b4cf539739df2c5dacb4c659f2488d#code) 复制过来。
    - 在remix中获取 UniswapV2Factory.sol 中 CONTRACT 为 UniswapV2Pair 时 Bytecode 的object对象，粘贴到 [keccak_256](http://emn178.github.io/online-tools/keccak_256.html) 后获取hash值(注意要用hex模式)，替换 UniswapV2Router02.sol 中的 initCode 码（之所这么做是因为Router需要通过这个hash找到Pair的地址，而hash会随着编译环境的改变而变化，真他妈是个鬼才！）
    - 允许 Enable optimization（不然会因为bytecode 过长部署失败）进行编译。
  - 部署设置
    - 填入上面的 Factory 和 WETH 地址之后，CONTRACT 选择 UniswapV2Router02，ENVIRONMENT 选择 Injected Web3
    - 连接 MetaMask 的 Rinkeby 网络进行部署。

## 部署前端

- 编译环境
  - ubuntu 20.04 
  - node v16.13.0
  - npm 8.1.4
  - yarn 1.22.17

- 下载项目
  - 下载 Uniswap-v2 版的interface，这里我选择的 uniswap-interface 版本是 [v2.6.5](https://github.com/Uniswap/interface/releases/tag/v2.6.5) 。

- 安装运行
  - 进入项目根目录后，执行 `yarn && yarn start` ，安装好依赖后确认可以成功启动。

- 替换地址
  - 项目根目录下检索(包括 `node_modules/@uniswap/`)“0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D”替换成你部署的 router 地址
  - 检索“0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f”替换成你部署的 factory 地址
  - 检索“96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f”替换成你部署 Pair 的 initcode
  - 检索“0xc778417E063141139Fce010982780140Aa0cD5Ab”替换成你部署的 WETH 地址

- 重新执行
  - 执行 `yarn start`，测试添加流动性和 swap 交易。

## 发布到github

- 安装gh-pages
  - `yarn add gh-pages`

- 生成前端代码
  - `yarn build`

- 修改配置文件
  - 修改`package.json`文件中的`"homepage"`属性为`"https://用户名.github.io/项目名称"`
  - 添加`package.json`文件中的`"scripts"`属性`"deploy": "gh-pages -d build"`

- 发布项目到github
  - `git add .`
  - `git commit -m "first commit"`
  - `git push`

- 部署前端界面
  - `yarn deploy`
  - 访问页面`"https://用户名.github.io/项目名称"`(需要一段时间剩生效)，我部署成功的地址为 [https://33357.github.io/uniswap-v2](https://33357.github.io/uniswap-v2)。
