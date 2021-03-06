# Uniswap-v2 项目历史

## 以下文章摘自 [Uniswap，去中心化交易所的诞生](https://zhuanlan.zhihu.com/p/350005943) 原作者联系可删除或申请贡献

2017年7月6日，Hayden Adams从大学毕业后入职的第一份工作是在西门子做机械工程师，糟糕的是他被公司解雇了。感到焦虑的他对生活失去了方向，向朋友Karl Floersch寻求安慰，当时的Karl正在以太坊基金会研究Casper FFG，Karl告诉他应该关注下以太坊，它是未来。现在入场还不算晚，你只需要在上面编写智能合约。

以太坊第一次进入了Hayden的生活，接下来两个月，Hayden学习了Ethereum、Solidity和Javascript。在Karl的建议下，他决定用刚学完的语言来编写2006年10月份Vitalik在Reddit上写的《Let’s run on-chain decentralized exchanges the way we run prediction markets》，描述了一个在区块链上运作的去中心化交易所的交易原型。

11月，Hayden搭建了一个概念验证，包括一个智能合约和一个网站，合约只有一个流动性提供者，也只允许几种代币兑换交易。

经过这次尝试，Hayden看到了自动化做市商对用户体验的影响，根据Vitalik的论文描述，传统的订单薄交易中，做市商或者交易双方会按照不同的价位分别下单，根据价位来提供不同的流动性。

而论文采用的是AMM机制，则是将所有人的资产汇集到流动池中，并根据一种名为“恒定乘积做市模型”的算法进行做市交易，“恒定乘积”可以看成一种反比例函数”X*Y=Z”,无论X和Y怎么改变，Z始终是一个定值，在Uniswap的AMM交易系统中就是指某次交易前后流动池里的两种代币数量的乘积是恒定的，即：买前乘积 = 买后乘积。

举个例子来说：我们在Uniswap上免费创建一个ETH与UMI的流动池，创建时ETH的数量和UMI的数量分别是10ETH和100UMI，这个时候UMI的价格为0.1ETH，两者的乘积为1000。

假设，Alice用1个ETH来买UMI，这个时候1ETH进入流动池，ETH流动池的数量变成11，要保持两种乘积不变的话，流动池中的UMI就要减少，这个减少的UMI数量即为1个ETH能买到的UMI数量，根据公式可以得到：

10 ETH * 100UMI = （10+1）ETH * （100-X）UMI

计算得到的X = 9.09UMI，即1个ETH可以买到9.09UMI，相对于原来1ETH=10UMI的价格来说，价格误差（滑点）为：

（10-9.09）/ 10 *100% =9.09%

将1个ETH改成5个ETH，可以算出5个ETH可以买到33.33个UMI,一个ETH只能够买到6.67个UMI，滑点为33.33%。

为了保持两种代币价格兑换比例不会被改变，需要按比例数量的两种代币同时注入流动池中。这样一来，乘积会被扩大，但是两种代币的兑换价格并未改变。

以上就是整个AMM机制的核心算法了，Hayden说这是他一生中做过的最有趣的事情，做的有点甚至不像工作。

当时，EtherDelta是唯一具有交易功能的去中心化交易平台，但给人的感觉混乱，数据不够直观，Hayden Adams感觉自己的版本更好。

11月1日，以太坊第三次开发者大会在墨西哥的坎昆召开，Karl在活动上讲Uniswap用于加密经济和开源金融应用案例的例子，当时参会的Pascal Van Hecke辗转找到了Hayden，表示有兴趣并提出了一些新的想法，这些沟通理清了思路和需要解决的一些问题（简化交易，只提供 ETH/ERC20 交易对，只为流动性提供者LP提供服务）。

12月，他和Karl前往参加一个名为NYC Mesh 的会议，会场上Karl被 Coindesk的记者认了出来，他不想接受采访，并向记者引荐了Hayden，谈了一些观点之后并被记者引用到一篇文章中。

2018年1月底，在更新完Uniswap的合约后，Hayden联系上了自己从小学到高中的Callil Capuozzo同学，两人对项目进行了详细讨论，Callil主动帮忙处理前端业务，构建了一个新界面。

2月，Hayden又联系上了大学的Uciel Vilchis(后来他在Karl的建议下加入了Uniswap团队）。当时，Uciel刚从一个编程训练营出来，由于Hayden的编程能力太糟糕，当时还对他说，你应该学学怎么编程，而他自己失业快5个月了，靠着早些时候买的加密货币度日，如果有适合Solidity-native开发工作的话，还想着是时候可以换个工作了。

3月，三个人完成了一个功能齐全的Uniswap演示版本。

4月，Hayden赖以生存的加密货币下跌了75%以上。尽管如此，他还是买了最后一班飞往韩国首尔的机票。这算是他24年的人生中第一次离开北美。

Karl把他引荐给Vitalik，当时的对话大概是这样的：

Karl: 这是我的朋友Hayden，他搞出了Uniswap！

Vitalik:你好，很高兴见到你！它是开源的吗?

Hayden Adams:当然了!

Vitalik:网址是什么?

Hayden Adams:https://github.com/haydenadams/uniswap

Vitalik在他的手机上阅读了整个智能合约，你考虑过用Vyper写吗? 另外，你应该申请以太坊基金会的资助。

回国后，Hayden 听从Vitalik的建议重新用Vyper编写了合约。后来在一个小型社交聚会上碰到了Philip Daian、 Dan Robinson和Andy Milenius，他们成了好朋友，并一起为Uniswap的成功添砖加瓦。

5月，Hayden飞往多伦多参加Edcon 2018，他在活动上发表演讲，展示了 Uniswap。

Hayden和他的四个朋友都在现场，也为他引荐了更多的人。在所有新朋友中，给Hayden留下深刻印象的是Jinglan Wang，她后来为 Uniswap提供了许多建议，在回纽约的飞机上，Hayden和新认识的Dan Robinson一起优化 Uniswap。

Hayden继续参加了纽约区块链周的各种活动和派对，直到他看到以太坊钱包初创公司Balance的创始人Richard Burton 一条活动推特，由于也就15分钟路程，于是决定去看看。

在观看了Demo 后，Richard Burton希望知道Uniswap是如何运作的，接下来就是一场漫长的对话，这一次经历，也让Hayden明白，如果他想让人们使用Uniswap，他需要让用户理解，Uniswap最大的挑战在于如何让大家接受。

接下来Hayden白天在Balance的办公室工作，继续完善协议，编写白皮书，业务时间参加活动，还申请了以太坊的Grant，Richard知道他的资金快用完了，还给了他一笔资助资金。

Balance的办公区有一个传统，每周三都会有两个小时的分享时间，大家会分享近期主攻加密项目的进展，而Hayden几乎每周都参加，向不同的人群反复解释Uniswap，他学会了如何在不同的场合谈论Uniswap，并且很快就能向几乎所有人解释它，这时候他也开始尝试使用社交媒体。

后来Hayden还在Maker的办公司待过一段时间，他遇到了包括 Ashleigh Schapp在内的很多MakerDAO的朋友。

7月，Hayden收到了一封电子邮件，Uniswap得到了以太坊基金会的10万美元资助，Uniswap的落地速度加快了，虽然Uniswap还没有公布，但这个项目已经不是个秘密。

9月，Hayden应邀前往一个在香港举行的以太坊产业发展峰会ETHIS并发表演讲。活动上，Hayden又遇到了Vitalik，他看了Uniswap的最终代码，还发现了一个错误：误把“recipient”拼成“recipeint”。

Hayden还无意进了一个以太坊基金会关于 ETH 2.0 的采访，第一次成了MEME的主角，回到纽约后，就决定在布拉格 Devcon 4 大会的最后一天发布Uniswap。

这是他度过迄今为止最忙碌的5周，大约在Devcon的前一周，Hayden完成了文档和白皮书，一些朋友帮助Uniswap解决了更细致的前端和代码等问题。此外，Hayden还精心准备了专为Uniswap发布而设计的卫衣。

2018年11月2日，怀着焦躁不安的心情在推特上发布了Uniswap正式上线的消息，当时他的推特只有200名粉丝。对很多人来说，Uniswap是一个全新的物种，而对Hayden来说，这是他过去一年多努力的结果。

正式上线后，激动的Hayden花了近一个小时写了改，改了写Uniswap上线的推文，当时朋友Ashleigh刚好路过，帮忙确认了推文后，他才按下发布的按钮。

2019年4月，Uniswap以500万美元的前期估值从Paradigm那里募集了182万美元的种子融资，Paradigm成立于2018年加密资产的熊市，由Matt huang、Fred Ehrsam和Charles Noyes创立。在众多加密投资机构中，只有Paradigm与A16z crypto的资金来自耶鲁大学的捐赠基金。

Matt Huang的父亲是黄奇辅，毕业于斯坦福大学商学院，1989年获得麻省终身教授职位。1994年在取得J.C.Penney的金融教授称号后决定离开学术界，进入金融投资领域。先是去了高盛，然后去了长期资本管理公司担任主要合伙人，从事对冲基金管理，负责亚太地区业务。在90年代中期，长期资本鼎盛时期，黄奇辅管理的资产相当于中国的国内生产总值，Matt Huang作为黄奇辅的大儿子，顺着父亲的路径一步步往上走，就读于麻省理工数学系，去高盛实习。

大学毕业后，和同学创立一家科技公司，几年后被Twitter收购。2014年被美国红杉资本挖走后，管理第6期9-10亿美元的成长基金，在红杉的4年中，Matt Huang领导了多次对加密领域创业公司的投资，最成功的投资是对今日头条的投资，该笔投资在6年内估值增长超过了2500倍。最终决定在2018年6月离开红衫，创立加密资产投资公司Paradigm。

Fred Ehrsam在加密领域市场声名远扬，从最开始在高盛担任交易员，随后加入Coinbase，成为联合创始人。接着辞去Coinbase的职务，只担任董事会成员。

Charles Noyes是来自于Pentera Capital的投资总监，2014年3月，Pentera宣布将投资中心转向比特币和其他加密资产相关的投资。

到2019年底，Uniswap锁定额总价值是2910万美元。

2020年5月，Uniswap推出升级版本Uniswap V2。相对于V1只接受ERC20与ETH的资金池兑换，V2版本启用了交叉兑换，通过降低gas fees以及减少滑点来改善执行价格，V2版本还引用了新的价格Oracle和闪兑功能。

6月份，Uniswap在A轮融资中以3900万美元的前期估值筹集了1100万美元，由Andreessen Horowitz与Union Square Ventures、Version One、Parafi Capital、Variant、SV Angel和A.Capital领投，Paradigm也参与了A轮融资。

6月中旬，Compound发起了一个核心的DeFi借贷协议，并开启了流动性挖矿，DeFi开始迅猛增长。

作为去中心化交易所，Uniswap向用户收取0.3%的交易手续费。与一般交易所不同的是，Uniswap的手续费是全部分配给流动性提供者（做市商LP），在市场活跃的时候，仅手续费一项，做市商每天可以获得上百万美元的收入，年化收益率达到20-50%之间。

但Uniswap出现了一个系统致命的问题就是没有自己的代币，在2020年所有的DeFi相关的项目中，有两方面引起市场的关注，主要集中在流动性挖矿和治理代币，Synthetix是第一个引入流动性挖矿的项目，Compound发行的治理代币COMP在行业内引发连锁反应，从项目的热度和活跃地址数的关系中，可以看到：

COMP，在一周内UAW数量从300左右增加至2700，增幅800%；BAL，在一周内UAW数量从200左右增加到650，增幅225%；CRV，在一周内UAW数量从1000左右增加到4100，增幅310%；

COMP成为DeFi的引领者，流动性挖矿和治理代币为加密领域注入了激励模型，短短两个月内，DeFi的锁仓总值飙升了9倍多。

YFI则将流动性挖矿推到了极致，没有创始人份额，也没有投资者份额，完全通过挖矿的模式将代币分发出去，并将代币作为社区治理的工具。这让DeFi的挖矿进入了全新的阶段，随之而来的是YAM对AMPL的分叉，并采用YFI的挖矿分配机制，激发了整个DeFi领域的灵感。

8月28日，谋划已久的Sushiswap看准时机，启动Uniswap的克隆版本，当天锁仓金额就达到近3亿美元，Sushiswap除了拥有Uniswap相同的前端UI和功能之外，还针对Uniswap推出了流动性挖矿和流动性迁移的两项计划：

流动性挖矿，即用户在Uniswap中创建的资产池同时可以获得Uiswap LP代币，持有Uniswap LP代币的任何人都可以将这些LP代币放到相应的资金池列表中。

SushiSwap在区块高度10750000开始奖励，每个区块产生100个Sushi代币，这些代币将平均分配给每个支持资金池的抵押者，其中前100000个区块（约2周时间），产生的Sushi代币数量是以后的10倍，即每个区块生产1000个Sushi代币，初始的资金池：

USDT-ETH,USDC-ETH;DAI-ETH,sUSD-ETH；

COMP-ETH,LEND-ETH;

SNX-ETH,UMA-ETH;

LINK-ETH,BAND-ETH;

AMPL-ETH,YFI-ETH;

SUSHI（2倍奖励）：SUSHI-ETH

SUSHI-ETH资金池可以获得两倍奖励，因此请把你的SUSHI放到Uniswap里，从而获得额外的奖励，也就是说SushiSwap 的资产都在UniSwap。

9月1日，SUSHI 代币同时上线OKEx、火币、币安、FTX交易所。

在SushiSwap的抵押资产几乎达到最高值，也就是9月3日，SushiSwap创始人Chef Nomi发起迁移流动性提案，也就是要将资产从 UniSwap 中转移走。

9月4日，SBF发起提案：SushiSwap将流动性集成到Serum中，并将提供SRM作为奖励。

9月5日，SushiSwap创始人Chef Nomi悄无声息的套现ETH 17971个，总价值约630万美元（根据 theblockcrypto 报道套现为37,400 ETH，约1300万美元）。

消息传开社区炸开了锅，并引发投资者的恐慌，从9月5日最高5美元跌至9月6日最低1.11美元，跌幅近 80%。

9月6日，Chef Nomi宣布将Sushiswap的控制权私钥移交给SBF（FTX 的CEO Sam Bankman-Fried）。SBF是个现实中的人，而Chef Nomi只是个虚拟的人，没有人承认自己是Chef Nomi，SBF发起新的流动性迁移提案。

9月7日，Band项目的CTO否认自己是SushiSwap的创始人Chef Nomi。

9月11日，轰轰烈烈的流动性开始迁移了，用户在Uniswap上赎回原来的代币，放到Sushiswap流动性资金池上，这些新的Sushiswap资金池将与Uniswap资金池相同，不同的是其中的0.05%的交易费用会直接分配给Sushi代币持有者。抵押者不需要做任何事情，可以继续提供流动性从而获得Sushi代币奖励。

Sushiswap成功的从Uniswap中带走了13亿美元的做市资金，锁仓量仅次于当时排名第一的AAVE，而Uniswap锁仓量仅剩4.7亿美元，排名12。

面对来势汹汹的对手，形势到了它不得不反击的阶段。如果Uniswap再不发币，整个格局就要发生改变。

不仅仅是SushiSwap，其他的各种swap也看到了这种机会，纷纷推出自己的swap，试图不仅分叉Uniswap，还要挖走它的流动性。

9月9日，Hayden的一条推文中的配图明示发币计划。

9月17日，Uniswap宣布正式发布协议代币UNI，初始铸造量为 10 亿枚，初始供应量会在未来4年内完成分发，其中：

60.00％，分发给Uniswap社区成员；

21.51%， 分发给当前以及未来 4 年内加入团队的成员；

17.80%，分发给项目投资者；

0.69％，分发给项目顾问；

4年后UNI将开始每年2%的持续通胀，以保证能够有足量的UNI来激励那些参与以及为项目发展做出贡献的用户。

在启动时，有15%的UNI代币由历史用户（10.06%，每个唯一地址400个）、流动性提供者（4.92%，V1部署以来按每秒钟比例计算）和SOCKS兑换者/持有人（0.02%，每个唯一地址1000个）根据2020年9月1日上午12:00的快照进行认领。除分配给老用户的占总量 15 ％的代币外，治理金库将保留UNI总供应量的 43％。以此保证对于贡献者捐赠、社区倡议、流动性挖矿等其他分配计划的顺利进行。

治理金库的 UNI 将会在未来四年内逐步解锁，解锁时间从2020 年 10 月 18 日 20:00 正式开始：

第一年将解锁预留总量的 40%（172,000,000 UNI）；

第二年解锁 30%（129,000,000 UNI）；

第三年解锁 20%（86,000,000 UNI）；

第四年解锁 10%（43,000,000 UNI）。

团队预留以及项目投资者和顾问分配到的代币也会以相同的比例在未来四年时间里逐渐释放。

初始流动性挖矿计划将于2020年9月18日20:00正式启动。第一阶段将运行至2020年11月17日20:00。Uniswap v2 上的ETH/USDT、ETH/USDC、ETH/DAI 以及 ETH/WBTC 四个流动性资金池将支持UNI挖矿。

第一阶段每个资金池都将获得共计5,000,000 UNI，按照提供流动性的比例分配给流动性提供者。即每个池每天将分配83,333.33 UNI 奖励。这部分奖励的UNI将不设锁定期。

30天后项目的投票治理将正式启动，UNI持有者可以通过投票决定是否新增其他的流动性资金池用以进行流动性挖矿以及其他的治理计划，初始治理参数：

需要 UNI 供应量的 1％进行授权UNI 供应量的 4% 投赞成票七天投票期投票结束后两天执行

Uniswap发币后，瞬间翻转盘面，各大交易所以惊人的速度上线了UNI。Uniswap再度点燃了DeFi市场，挤爆了以太坊网络，单次转账Gas费用最高达到1000gwei，创下历史新高。

SushiSwap的出现，就好像打开了魔盒，这个魔盒的关键就在于SUSHI代币的玩法，也引发了社区代币对抗VC代币之间的冲突。Tomochain创始人在推特上关于VC还是社区资本会赢的投票，社区资本以62.7%的票数胜出。

COMP是一个VC币，背后有Coinbase和a16z，如果Uniswap发币也同样属于VC币，这些刚上线的时候价格会很高。同时，VC会提前获得代币。

而社区币的代表，比如Aave、YFI，这些项目完全靠社区驱动。YFI的火热让我们看到了无预挖、社区参与公平性对于社区的驱动能力，而Uniswap背后投资人对于Sushiswap的激烈反应，也与Compound看到dForce旗下飞速升起的http://lendf.me的反应一模一样。

在毫无预算和宣传的情况下，Aave的锁仓量一度达到了DeFi 领域第一，YFI市值在DeFi领域排名第三，靠社区驱动，影响力远超VC。

大家想要的，就是我们能与 VC 公平竞争，区块链从来不会改变财富分配，社区币也不能阻止资金大户入场，但起码，大户和我们都同时进场的，我的一块钱，与大户的一块钱，在同样的时间内，可以获得同样的奖励，这就足够了。

12月1日，YFI宣布与Sushiswap达成合作，并将YFI迁移至Sushiswap上，除此之外，AC还表示将与Sushi合作推出借贷平台BentoBox，允许投资者以去中心化的方式做空和做多大量的资产。

12月11日，Hayden推特上发布称V2 Router02已经批准了780万次，如果平均批准费用约为0.5美元，则意味着已经产生480万美元，每天在Uniswap上产生了42万美元的Gas交易费用，每年将产生大约1.5亿美元的Gas费用，这非常清楚地说明了以太坊Layer2解决方案的重要性。

Uniswap和Sushiswap开始走向不同的道路，Uniswap向左聚焦于AMM模式的V3版本。而Sushiswap向右开始考虑借贷、Mirin、跨链等更多DeFi产品，试图摆脱Sushiswap的影子。

2020年12月30日，Uniswap锁定额总价值达到22.2亿美元。
