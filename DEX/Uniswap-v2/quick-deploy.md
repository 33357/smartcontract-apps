# 快速部署 Uniswap-v2

这是一套自动化部署Uniswap-v2的代码，可以实现快速部署Uniswap-v2

## 快速部署是如何实现的

要实现快速部署Uniswap-v2，其本质上是实现Uniswap-v2合约部署和配置的自动化。这里面合约自动部署使用到了hardhat框架，合约自动配置则使用到了[uniswap/sdk-core v3.0.3](https://github.com/Uniswap/sdk-core/tree/a88048e9c4198a5bdaea00883ca00c8c8e582605)(为了找到这个两年前的版本，可费了我不少时间)。只要用魔改后的SDK换掉原来的`uniswap/sdk`,就可以实现在前端项目里自动化配置合约。

祝大家玩的开心。

## 部署环境

- ubuntu 20.04 
- node v16.13.0
- npm 8.1.4
- yarn 1.22.17

## 快速部署Uniswap-v2合约

- 获取测试代币

    我们选择Rinkeby测试网络部署Uniswap-v2，首先需要获取测试代币。

    - [官方的水龙头](https://faucet.rinkeby.io/)，需要在twitter发帖

    - 这里推荐通过更加简单的 [chainlink水龙头](https://faucets.chain.link/rinkeby) 获取测试用代币。

- 下载项目
    - [uniswap-v2-contract](https://github.com/33357/uniswap-v2-contract)

- 配置编译环境
    - 在根目录下创建文件`/envs/env.rinkeby`,内容为：
        ```
        PRIVATE_KEY={有测试币的测试用私钥}
        RINKEBY_INFURA={infura节点的PROJECT_ID} 注册网址：https://infura.io/
        APIKEY={etherscan的APIKEY} 注册网址：https://etherscan.io/login
        ```

- 安装依赖并编译合约
    ```
    yarn && yarn build
    ```
- 部署合约
    - 设置部署环境
        ```
        export ENV_FILE='./envs/env.rinkeby'
        export NETWORK_ID=4
        export WAIT_NUM=1
        export GAS_PRICE=3
        ```
    - 执行部署命令
        ```
        yarn run env-cmd -f $ENV_FILE yarn run hardhat UniswapV2:deploy --gas-price $GAS_PRICE --wait-num $WAIT_NUM --network $NETWORK_ID
        ```
- 编译SDK
    - 进入SDK目录
        ```
        cd sdk
        ```
    - 安装依赖并编译SDK
        ```
        yarn && yarn build
        ```
    - 修改`package.json`
        ```
        {
            "name": "@{你的npm用户名}/uniswap-v2-sdk", 注册网址：https://www.npmjs.com/signup
            ...
        }
        ```
    - 发布SDK到npm
        ```
        yarn publish
        ```

## 快速部署Uniswap-v2前端

- 下载项目
    - [uniswap-v2-interface](https://github.com/33357/uniswap-v2-interface)

- 配置环境
    - 修改`package.json`
        ```
        {
            ...
              "devDependencies": {
                ...
                "@{你的npm用户名}/uniswap-v2-sdk": {你发布的版本号},
        }
        ```
- 安装依赖并启动项目
    ```
    yarn && yarn start
    ```
- 测试添加流动性和 swap 交易。

- 发布到github
    - 生成前端代码
        ```
        yarn build
        ```
    - 修改配置文件
        - 修改`package.json`
        ```
            {
                ...
                "homepage": "https://{用户名}.github.io/{项目名称}"
            }
        ```
    - 发布项目到github
        ```
        git add .
        git commit -m "first commit"
        git push
        ```
    - 部署前端界面
        ```
        yarn deploy
        ```
    - 访问页面`https://{用户名}.github.io/{项目名称}`(需要一段时间剩生效)

