# 加密是一个整体，史上最大 DeFi 黑客事件总结

## 备注

时间：2026 年 5 月 1 日

作者：[33357](https://github.com/33357)

## 正文

### 事件概要

4 月 18 日，朝鲜黑客组织通过 RPC 投毒入侵了 LayerZero 运营的 DVN 节点，伪造了一笔跨链消息，从 KelpDAO 的 rsETH 跨链桥一次性盗取了 116,500 枚 rsETH（约 $2.92 亿）。事件的根源在于 KelpDAO 使用了 LayerZero 的默认 1-of-1 DVN 配置，整个桥只有一个验证节点，造成单点故障。

攻击者没有直接抛售，而是在 3 分钟内将约 89,567 枚 rsETH 存入 Aave V3 作为抵押品，借出约 82,650 WETH 和 821 wstETH（合计约 $1.93 亿）。这造成了链上最大借贷平台 AAVE 的大规模坏账，并引发了恐慌性挤兑。24 小时内约 $62 亿资产从 Aave 流出，ETH、USDT、USDC 池利用率全部飙至 100%，部分存款人完全无法提款。

4 月 21 日，Arbitrum 安全委员会通过紧急升级冻结了攻击者在 Arb 链上的 30,766 ETH（约 $7,150 万），追回约 25% 的被盗资产。4 月 24 日，Aave 主导成立 DeFi United 救助联盟，短短 4 天内筹集了 140,236 ETH（约 $3.18 亿） 的援助承诺，覆盖了全部亏空。参与方包括 Consensys、Mantle、Aave DAO、LayerZero、ether.fi 等十余个机构。

### 事件解读

这是 DeFi 历史上首次多协议协调救助。甚至竞品之间也进行了互相援助（ether.fi 帮 Kelp、Compound 帮 Aave），在没有监管机构介入的情况下 10 天内自发填补了 $2.9 亿的亏空，这是非常罕见的。为什么有这么多人愿意出钱帮助Aave，我认为有以下原因：

- 公开透明

黑客攻击的行为在链上公开可见，同样援助者的资金也受公众的监督，救助的成本和收益是高度确定的，而这种透明度在传统金融的危机处置中很难实现（例如 2022 年 FTX 的资产负债不透明导致无人援助）。

- 互相绑定

DEFI 的资金套娃游戏环环相扣，如果 AAVE 在这次事件中破产，很多以 AAVE 为底层资产的协议也会连带破产，这种多米诺骨牌效应引发的间接损失会远超黑客带来的直接损失。（例如 2008 年雷曼兄弟破产引发的全球金融危机）

- 一损俱损

黑客事件危害的是整个 DEFI 行业的信用，如果用户因为这次的黑客事件吓跑，整个产业的市场都会萎缩（例如 1983 年雅达利大奔溃摧毁了当时的游戏产业）。

### 总结

由于 DEFI 的开放和兼容性，加密行业实际上已经被紧密地连接成一个整体，这起事件的快速解决就是很好的体现。

### 事件时间线
| 时间 UTC+8 | 内容概要 | 源链接 |
|------|----------|--------|
| 2026-04-19 01:35| 黑客地址欺骗 LayerZero EndpointV2 合约从 KernelDAO Bridge 合约盗取 116,500 rsETH（约 $290M）。 | [Etherscan](https://etherscan.io/tx/0x1ae232da212c45f35c1525f851e4c41d529bf18af862d9ce9fd40bf709db4222) |
| 2026-04-19 01:38 | 黑客地址向 Aave 合约存入 rsETH 并借出大量 ETH。 | [Etherscan](https://etherscan.io/tx/0x9a7df4837aa8ca1e22f3f40ffee2fa583e9f0e1e31c970c4d34070e01038057d) |
| 2026-04-19 02:21 | KelpDAO 地址暂停了 KernelDAO Bridge 合约的功能。 | [Etherscan](https://etherscan.io/tx/0x4f52256ab6c8ab95d30cf994e0264f1de27e089764bb011824d5ddd47d9a1698) |
| 2026-04-19 03:03 | Aave Deployer 12 地址暂停了 Ethereum Core V3 的 rsETH 市场功能。 | [Etherscan](https://etherscan.io/tx/0xd40b8b3b5f5b0d7a5cba4b0d49a83a174eecf27d20b7c9ad2bb23a867d1c7176) |
| 2026-04-19 04:01 | Aave 宣布冻结 V3/V4 的 rsETH 市场，声明 Aave 合约本身未被攻破。 | [X](https://x.com/aave/status/2045593585966252377) |
| 2026-04-19 04:10 | KelpDAO 宣布发现可疑跨链活动，暂停主网及多个 L2 上的 rsETH 合约并启动调查。 | [X](https://x.com/KelpDAO/status/2045595819035046148) |
| 2026-04-19 10:15 | Aave 地址暂停了 Ethereum Core V3 的 WETH 市场功能 | [Etherscan](https://etherscan.io/tx/0xd5105e26a8f4f911e12359128ab8bfd2f7ad1484ccfe754ec9f05eb0474e2fe6) |
| 2026-04-20 03:17 | Aave 宣布更新：确认以太坊主网的 rsETH 完全有资产支撑，出于谨慎考虑 V3/V4 的 rsETH 市场继续冻结，受影响的 WETH 市场也保持冻结。 | [X](https://x.com/aave/status/2045944827510939696) |
| 2026-04-20 12:20 | LayerZero 发布声明：初步归因于朝鲜黑客攻击了自己运营的 DVN，目前只有 KelpDAO 受到影响，建议所有项目迁移到多 DVN 配置并不再为单 DVN 提供服务。 | [X](https://x.com/LayerZero_Core/status/2046081551574983137) |
| 2026-04-21 02:12 | Aave 地址重启了 Ethereum Core V3 的 WETH 市场功能 | [Etherscan](https://etherscan.io/tx/0xe5039d60af0f270107d8695368d8bfd70cda47e6a971e04230f3c0496997053d) |
| 2026-04-21 04:14 | Aave 发布报告：攻击者将 89,567 rsETH 存入 Aave 借出约 $193M，并建模两种坏账场景：1、全网承担损失：坏账约 $1.24 亿，2、仅 L2 承担损失：坏账约 $2.30 亿。| [X](https://x.com/aave/status/2046321565197905982) |
| 2026-04-21 04:55 | KelpDAO 补充说明：是 LayerZero 托管的节点遭到黑客入侵，自己使用的单 DVN 是默认配置，要和 AAVE、 LayerZero 合作解决问题。 | [X](https://x.com/KelpDAO/status/2046332070277091807) |
| 2026-04-21 11:26 | Arbitrum 地址对 Ethereum 主网 Inbox 合约进行临时升级，新增 `sendUnsignedTransactionOverride` 函数，冒充黑客地址将 Arb 链上的 30,766 ETH 转移至特定地址 `0x0000000000000000000000000000000000000DA0`。 | [Etherscan](https://etherscan.io/tx/0x079984c56c5670108f5c6f664904178f9b364340351949a42e4637d1f645f770) [Arbscan](https://arbiscan.io/tx/0x5618044241dade84af6c41b7d84496dc9823700f98b79751e257608dac570f6b) |
| 2026-04-21 11:46 | Arbitrum 宣布安全委员会采取紧急行动，冻结了 ARB 上攻击相关地址的 30,766 ETH。 | [X](https://x.com/arbitrum/status/2046435443680346189) |
| 2026-04-21 14:18 | Aave 宣布解冻 Ethereum Core V3 的 WETH 市场，其他网络的 WETH 市场仍冻结。 | [X](https://x.com/aave/status/2046473573905133953) |
| 2026-04-22 08:45 | 余烬 宣布黑客开始通过 THORChain 将 ETH 兑换为 BTC 进行洗钱，截至报告时已洗走约 34,500 ETH（~$80M）。| [X](https://x.com/EmberCN/status/2046752272890372462)|
| 2026-04-24 01:45 | LidoFinance 宣布提案 Lido DAO 提供最多 2,500 stETH 至 Aave 协调的 rsETH 救助工具 DeFi United。 | [X](https://x.com/LidoFinance/status/2047371180781539827) |
| 2026-04-24 01:46 | Aave 宣布主导 DeFi United 以恢复 rsETH，已有多方承诺参与。 | [X](https://x.com/aave/status/2047371627285848312) |
| 2026-04-24 03:12 | ether.fi Foundation 宣布提案向 rsETH 专项救助工具贡献 5,000 ETH。 | [X](https://x.com/ether_fi_Fdn/status/2047393169776492798) |
| 2026-04-24 04:32 | Stani Kulechov (Aave 创始人) 宣布以个人名义贡献 5,000 ETH 至 DeFi United。 | [X](https://x.com/StaniKulechov/status/2047413237113868576) |
| 2026-04-24 06:21 | Golem Foundation 宣布和 Golem Factory 从国库联合贡献 1,000 ETH 至 DeFi United。 | [X](https://x.com/GolemFoundation/status/2047440757900906535) |
| 2026-04-24 08:43 | Mantle 宣布提案 Mantle Treasury 向 Aave DAO 提供至多 30,000 ETH 的贷款。| [X](https://x.com/Mantle_Official/status/2047476407182516628) |
| 2026-04-24 17:14 | Ernesto 宣布个人向 Aave Labs 协调的救助行动捐赠 100 ETH。 | [X](https://x.com/eboadom/status/2047605083852898414) |
| 2026-04-24 17:36 | BGD 宣布向 Aave Labs 协调的救助基金贡献 250 ETH。 | [X](https://x.com/bgdlabs/status/2047610571231518801) |
| 2026-04-24 17:49 | Emilio 宣布向 DeFi United 承诺贡献 500 ETH。 | [X](https://x.com/The3D_/status/2047613979539739112) |
| 2026-04-25 02:10 | Aave 宣布向 Aave DAO 提案为 DeFi United 贡献 25,000 ETH。 | [X](https://x.com/aave/status/2047740040218816739) |
| 2026-04-25 05:34 | Keyring Network 宣布将向 DeFi United 贡献 20 ETH。 | [X](https://x.com/KeyringNetwork/status/2047791408015192339) |
| 2026-04-25 12:23 | Sam Mason de Caires 宣布已搭建贡献追踪仪表盘 https://defiunited.world 为大家使用。| [X](https://x.com/sammdec/status/2047712948647338036) |
| 2026-04-25 21:35 | Aave 宣布与 Ether.fi、KelpDAO、LayerZero、Compound 等向 Arbitrum DAO 提交治理提案，要求释放 Arbitrum 安全委员会冻结的 30,766 ETH 进入 DeFi United。 | [X](https://x.com/aave/status/2048033243727806909) |
| 2026-04-26 08:10 | KelpDAO 宣布向 DeFi United 贡献 2000 ETH。 | [X](https://x.com/KelpDAO/status/2048193002615799838) |
| 2026-04-27 19:09 | Marcelo Ruiz de Olano 宣布个人向 defiunited.world 贡献 100 ETH。 | [X](https://x.com/claberus/status/2048721258238333426) |
| 2026-04-27 21:39 | Consensys 宣布向 DeFi United 贡献 30000 ETH。 | [X](https://x.com/Consensys/status/2048758840959578577) |
| 2026-04-28 04:44 | Compound 宣布向 DeFi United 贡献 3000 ETH。 | [X](https://x.com/Compound_xyz/status/2048865871096168838) |
| 2026-04-28 10:51 | Aave 宣布 DeFi United 已筹集足够的承诺援助，将恢复 rsETH 的底层资产，清理受影响的仓位并恢复市场的正常运营。 | [X](https://x.com/aave/status/2048958367658332413) |
| 2026-04-29 02:46 | LayerZero 宣布向 DeFi United 贡献 5000 ETH。 | [X](https://x.com/LayerZero_Core/status/2049198660068802867) |
