# rsETH 被盗2.9亿美元时间线整理

## 备注

时间：2025 年 4 月 24 日

作者：[33357](https://github.com/33357)

## 正文

最近大新闻莫过于 KelpDAO 的 rsETH 被盗事件，各种消息非常繁杂。这是我整理的各方在链上和 X 上重要响应的时间线，希望能帮助大家迅速理清事件脉络。

| 时间 UTC+8 | 内容概要 | 源链接 |
|------|----------|--------|
| 2026-04-19 01:35| 黑客地址通过欺骗 LayerZero EndpointV2 合约，从 KernelDAO Bridge 合约盗取 116,500 rsETH（约 $290M）。 | [Etherscan](https://etherscan.io/tx/0x1ae232da212c45f35c1525f851e4c41d529bf18af862d9ce9fd40bf709db4222) |
| 2026-04-19 01:38 | 黑客地址开始陆续向 Aave 合约存入 rsETH 并大量借出 ETH。 | [Etherscan](https://etherscan.io/tx/0x9a7df4837aa8ca1e22f3f40ffee2fa583e9f0e1e31c970c4d34070e01038057d) |
| 2026-04-19 02:21 | KelpDAO 地址暂停了 KernelDAO Bridge 合约功能。 | [Etherscan](https://etherscan.io/tx/0x4f52256ab6c8ab95d30cf994e0264f1de27e089764bb011824d5ddd47d9a1698) |
| 2026-04-19 03:03 | Aave Deployer 12 地址冻结了 Ethereum Core V3 rsETH 的功能。 | [Etherscan](https://etherscan.io/tx/0xd40b8b3b5f5b0d7a5cba4b0d49a83a174eecf27d20b7c9ad2bb23a867d1c7176) |
| 2026-04-19 04:01 | Aave 宣布冻结 Aave V3/V4 所有 rsETH 市场，禁止其新存款和借贷；声明 Aave 合约本身未被攻破。 | [X](https://x.com/aave/status/2045593585966252377) |
| 2026-04-19 04:10 | KelpDAO 宣布发现可疑跨链活动，暂停主网及多个 L2 上的 rsETH 合约，启动调查并与 LayerZero、Unichain、审计机构及安全专家合作。 | [X](https://x.com/KelpDAO/status/2045595819035046148) |
| 2026-04-19 10:15 | Aave 地址冻结了 Ethereum Core V3  WETH 的功能 | [Etherscan](https://etherscan.io/tx/0xd5105e26a8f4f911e12359128ab8bfd2f7ad1484ccfe754ec9f05eb0474e2fe6) |
| 2026-04-20 03:17 | Aave 发布更新：确认以太坊主网 rsETH 完全有支撑；出于谨慎 rsETH 仍保持冻结，受影响市场的 WETH 也冻结。 | [X](https://x.com/aave/status/2045944827510939696) |
| 2026-04-20 12:20 | LayerZero 发布事件声明：初步归因于朝鲜 Lazarus Group（TraderTraitor）的国家级攻击，攻击方式为毒化 DVN 下游 RPC 节点并配合 DDoS；强调事件仅影响 Kelp 的 1-of-1 DVN 配置，LayerZero 协议本身及其他应用零感染；宣布不再为 1/1 配置签名。 | [X](https://x.com/LayerZero_Core/status/2046081551574983137) |
| 2026-04-21 04:14 | Aave 宣布 LlamaRisk 发布详细事件报告：攻击者将 89,567 rsETH 存入 Aave 借出约 $193M；建模两种坏账场景：1、全网承担坏账约 $1.24 亿，2、仅 L2 承担坏账约 $2.30 亿；DAO 资产负债表约 $1.81 亿可用于覆盖损失。 | [X](https://x.com/aave/status/2046321565197905982) |
| 2026-04-21 04:55 | KelpDAO 发布补充说明：是 LayerZero 托管的两个 RPC 节点遭到入侵，Kelp 自身的系统未受直接攻击。1-of-1 DVN 是 LayerZero 默认配置且曾被确认适当；Kelp 检测异常后暂停合约、黑名单攻击者钱包、阻止了第二笔 40,000 rsETH（~$95M）的攻击尝试。 | [X](https://x.com/KelpDAO/status/2046332070277091807) |
| 2026-04-21 11:26 | Arbitrum 地址对 Ethereum 主网 Inbox 合约进行临时升级，新增 `sendUnsignedTransactionOverride` 函数，冒充黑客地址将 Arb 链上的 30,766 ETH 转移至特定地址 `0x0000000000000000000000000000000000000DA0`。 | [Etherscan](https://etherscan.io/tx/0x079984c56c5670108f5c6f664904178f9b364340351949a42e4637d1f645f770) [Arbscan](https://arbiscan.io/tx/0x5618044241dade84af6c41b7d84496dc9823700f98b79751e257608dac570f6b) |
| 2026-04-21 11:46 | Arbitrum 宣布安全委员会采取紧急行动，冻结 Arbitrum One 上与攻击相关地址中的 30,766 ETH，资金已转移至特定地址，后续处置需 Arbitrum 治理决定。 | [X](https://x.com/arbitrum/status/2046435443680346189) |
| 2026-04-21 02:12| Aave 地址解冻了 Ethereum Core V3  WETH 的功能 | [Etherscan](https://etherscan.io/tx/0xe5039d60af0f270107d8695368d8bfd70cda47e6a971e04230f3c0496997053d) |
| 2026-04-21 14:18 | Aave 宣布解冻 Ethereum Core V3 的 WETH 储备（LTV 仍为 0），其他市场 WETH 仍冻结。 | [X](https://x.com/aave/status/2046473573905133953) |
| 2026-04-22 08:45 | 余烬 宣布黑客开始通过 THORChain 跨链将 ETH 兑换为 BTC 进行洗钱，截至报告时已洗走约 34,500 ETH（~$80M）。THORChain 24h 交易量从日均 $2000 万暴增至 $3.6 亿，平台费用从日均 $5000 飙升至 $42 万。 | [X](https://x.com/EmberCN/status/2046752272890372462)|
| 2026-04-24 01:45 | LidoFinance 宣布向 Lido DAO 提交提案，建议一次性贡献最多 2,500 stETH 至 Aave 协调的 rsETH 救助工具，条件为完全资金到位后执行。 | [X](https://x.com/LidoFinance/status/2047371180781539827) |
| 2026-04-24 03:12 | ether.fi Foundation 宣布提议向 rsETH 专项救助工具贡献 5,000 ETH，保护用户并防止 DeFi 坏账。 | [X](https://x.com/ether_fi_Fdn/status/2047393169776492798) |
| 2026-04-24 04:32 | Stani Kulechov (Aave 创始人) 宣布以个人名义贡献 5,000 ETH 至 DeFi United 救助行动，继续与合作伙伴推进更多补偿承诺。 | [X](https://x.com/StaniKulechov/status/2047413237113868576) |
| 2026-04-24 06:21 | Golem Foundation 宣布 Golem Foundation 和 Golem Factory 从国库联合贡献 1,000 ETH 至 Aave 协调的 DeFi 救助行动。 | [X](https://x.com/GolemFoundation/status/2047440757900906535) |