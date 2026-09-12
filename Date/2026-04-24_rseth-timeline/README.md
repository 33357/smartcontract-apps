# rsETH 被盗2.9亿美元时间线整理

## 备注

时间：2026 年 4 月 24 日

作者：[33357](https://github.com/33357)

## 正文

最近大新闻莫过于 KelpDAO 的 rsETH 被盗事件，各种消息非常繁杂。这是我整理的各方在链上和 X 上重要响应的时间线，希望能帮助大家迅速理清事件脉络。

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


目前已经宣布的救助总额为: Lido 2,500 + ether.fi 5,000 + Stani 5,000 + Golem 1,000 + Mantle 30,000 + Ernesto 100 + BGD 250 + Emilio 500 + Aave 25,000 + Keyring 20 + Arbitrum 30,766 + KelpDAO 2,000 + Marcelo 100 + Consensys 30,000 + Compound 3,000 + LayerZero 5,000 = 140,236 ETH。


# rsETH $290M Theft — Timeline

## Notes

Date: April 24, 2025

Author: [33357](https://github.com/33357)

## Overview

The biggest recent news has been the KelpDAO rsETH theft. Information from various sources has been chaotic. Below is a timeline I compiled of key on-chain and X (Twitter) responses from all parties involved, intended to help everyone quickly understand how events unfolded.

| Time (UTC) | Summary | Source |
|------|----------|--------|
| 2026-04-18 17:35 | A hacker address spoofed the LayerZero EndpointV2 contract to steal 116,500 rsETH (~$290M) from the KernelDAO Bridge contract. | [Etherscan](https://etherscan.io/tx/0x1ae232da212c45f35c1525f851e4c41d529bf18af862d9ce9fd40bf709db4222) |
| 2026-04-18 17:38 | The hacker deposited rsETH into the Aave contract and borrowed a large amount of ETH. | [Etherscan](https://etherscan.io/tx/0x9a7df4837aa8ca1e22f3f40ffee2fa583e9f0e1e31c970c4d34070e01038057d) |
| 2026-04-18 18:21 | A KelpDAO address paused the KernelDAO Bridge contract. | [Etherscan](https://etherscan.io/tx/0x4f52256ab6c8ab95d30cf994e0264f1de27e089764bb011824d5ddd47d9a1698) |
| 2026-04-18 19:03 | The Aave Deployer 12 address paused the rsETH market on Ethereum Core V3. | [Etherscan](https://etherscan.io/tx/0xd40b8b3b5f5b0d7a5cba4b0d49a83a174eecf27d20b7c9ad2bb23a867d1c7176) |
| 2026-04-18 20:01 | Aave announced the freezing of the rsETH market on V3/V4, stating that the Aave contracts themselves were not compromised. | [X](https://x.com/aave/status/2045593585966252377) |
| 2026-04-18 20:10 | KelpDAO announced detection of suspicious cross-chain activity, paused rsETH contracts on mainnet and multiple L2s, and launched an investigation. | [X](https://x.com/KelpDAO/status/2045595819035046148) |
| 2026-04-19 02:15 | An Aave address paused the WETH market on Ethereum Core V3. | [Etherscan](https://etherscan.io/tx/0xd5105e26a8f4f911e12359128ab8bfd2f7ad1484ccfe754ec9f05eb0474e2fe6) |
| 2026-04-19 19:17 | Aave posted an update: confirmed that rsETH on Ethereum mainnet is fully backed by assets. Out of caution, the rsETH market on V3/V4 remains frozen, and the affected WETH market also remains frozen. | [X](https://x.com/aave/status/2045944827510939696) |
| 2026-04-20 04:20 | LayerZero issued a statement: preliminary attribution points to North Korean hackers compromising a DVN they operated. Only KelpDAO was affected so far. They advised all projects to migrate to a multi-DVN configuration and announced they would no longer support single-DVN setups. | [X](https://x.com/LayerZero_Core/status/2046081551574983137) |
| 2026-04-20 18:12 | An Aave address resumed the WETH market on Ethereum Core V3. | [Etherscan](https://etherscan.io/tx/0xe5039d60af0f270107d8695368d8bfd70cda47e6a971e04230f3c0496997053d) |
| 2026-04-20 20:14 | Aave published a report: the attacker deposited 89,567 rsETH into Aave and borrowed ~$193M. They modeled two bad-debt scenarios: (1) loss shared across the entire network: ~$124M in bad debt; (2) loss borne only by L2: ~$230M in bad debt. | [X](https://x.com/aave/status/2046321565197905982) |
| 2026-04-20 20:55 | KelpDAO provided additional clarification: it was the LayerZero-hosted node that was compromised. Their use of a single DVN was the default configuration. They plan to work with Aave and LayerZero to resolve the issue. | [X](https://x.com/KelpDAO/status/2046332070277091807) |
| 2026-04-21 03:26 | An Arbitrum address performed a temporary upgrade on the Ethereum mainnet Inbox contract, adding a `sendUnsignedTransactionOverride` function to impersonate the hacker's address and transfer 30,766 ETH on the Arbitrum chain to the address `0x0000000000000000000000000000000000000DA0`. | [Etherscan](https://etherscan.io/tx/0x079984c56c5670108f5c6f664904178f9b364340351949a42e4637d1f645f770) [Arbscan](https://arbiscan.io/tx/0x5618044241dade84af6c41b7d84496dc9823700f98b79751e257608dac570f6b) |
| 2026-04-21 03:46 | Arbitrum announced that its Security Council took emergency action to freeze 30,766 ETH associated with the attack on Arbitrum. | [X](https://x.com/arbitrum/status/2046435443680346189) |
| 2026-04-21 06:18 | Aave announced the unfreezing of the WETH market on Ethereum Core V3. WETH markets on other networks remain frozen. | [X](https://x.com/aave/status/2046473573905133953) |
| 2026-04-22 00:45 | 余烬 reported that the hacker began laundering funds by swapping ETH for BTC via THORChain. As of the report, approximately 34,500 ETH (~$80M) had been laundered. | [X](https://x.com/EmberCN/status/2046752272890372462) |
| 2026-04-23 17:45 | Lido Finance announced a proposal for Lido DAO to provide up to 2,500 stETH to DeFi United, an rsETH rescue facility coordinated by Aave. | [X](https://x.com/LidoFinance/status/2047371180781539827) |
| 2026-04-23 17:46 | Aave announced it is leading DeFi United to recover rsETH, with multiple parties already committed to participating. | [X](https://x.com/aave/status/2047371627285848312) |
| 2026-04-23 19:12 | The ether.fi Foundation announced a proposal to contribute 5,000 ETH to the rsETH rescue facility. | [X](https://x.com/ether_fi_Fdn/status/2047393169776492798) |
| 2026-04-23 20:32 | Stani Kulechov (Aave founder) announced a personal contribution of 5,000 ETH to DeFi United. | [X](https://x.com/StaniKulechov/status/2047413237113868576) |
| 2026-04-23 22:21 | Golem Foundation announced a joint contribution of 1,000 ETH from their treasury with Golem Factory to DeFi United. | [X](https://x.com/GolemFoundation/status/2047440757900906535) |
| 2026-04-24 00:43 | Mantle announced a proposal for the Mantle Treasury to provide a loan of up to 30,000 ETH to Aave DAO. | [X](https://x.com/Mantle_Official/status/2047476407182516628) |
| 2026-04-24 09:14 | Ernesto announced a personal donation of 100 ETH to the rescue effort coordinated by Aave Labs. | [X](https://x.com/eboadom/status/2047605083852898414) |
| 2026-04-24 09:36 | BGD announced a contribution of 250 ETH to the rescue fund coordinated by Aave Labs. | [X](https://x.com/bgdlabs/status/2047610571231518801) |
| 2026-04-24 09:49 | Emilio announced a commitment of 500 ETH to DeFi United. | [X](https://x.com/The3D_/status/2047613979539739112) |
| 2026-04-24 18:10 | Aave announced a proposal to Aave DAO to contribute 25,000 ETH to DeFi United. | [X](https://x.com/aave/status/2047740040218816739) |
| 2026-04-24 21:34 | Keyring Network announced a contribution of 20 ETH to DeFi United. | [X](https://x.com/KeyringNetwork/status/2047791408015192339) |
| 2026-04-25 04:23 | Sam Mason de Caires announced the launch of a contribution tracking dashboard at https://defiunited.world. | [X](https://x.com/sammdec/status/2047712948647338036) |
| 2026-04-25 13:35 | Aave announced that it, together with Ether.fi, KelpDAO, LayerZero, Compound, and others, submitted a governance proposal to Arbitrum DAO requesting the release of the 30,766 ETH frozen by the Arbitrum Security Council into DeFi United. | [X](https://x.com/aave/status/2048033243727806909) |
| 2026-04-26 00:10 | KelpDAO announced a contribution of 2,000 ETH to DeFi United. | [X](https://x.com/KelpDAO/status/2048193002615799838) |
| 2026-04-27 11:09 | Marcelo Ruiz de Olano announced a personal contribution of 100 ETH to defiunited.world. | [X](https://x.com/claberus/status/2048721258238333426) |
| 2026-04-27 13:39 | Consensys announced a contribution of 30,000 ETH to DeFi United. | [X](https://x.com/Consensys/status/2048758840959578577) |
| 2026-04-27 20:44 | Compound announced a contribution of 3,000 ETH to DeFi United. | [X](https://x.com/Compound_xyz/status/2048865871096168838) |
| 2026-04-28 02:51 | Aave announced that DeFi United has raised sufficient pledged support to restore the underlying assets of rsETH, unwind affected positions, and resume normal market operations. | [X](https://x.com/aave/status/2048958367658332413) |
| 2026-04-28 18:46 | LayerZero announced a contribution of 5,000 ETH to DeFi United. | [X](https://x.com/LayerZero_Core/status/2049198660068802867) |

Total announced rescue contributions to date: Lido 2,500 + ether.fi 5,000 + Stani 5,000 + Golem 1,000 + Mantle 30,000 + Ernesto 100 + BGD 250 + Emilio 500 + Aave 25,000 + Keyring 20 + Arbitrum 30,766 + KelpDAO 2,000 + Marcelo 100 + Consensys 30,000 + Compound 3,000 + LayerZero 5,000 = 140,236 ETH。