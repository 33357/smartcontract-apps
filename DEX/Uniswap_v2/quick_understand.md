# 快速了解 Uniswap-v2

## 去中心化交易所(DEX)

去中心化交易所是指使用智能合约，部署在区块链运行的非托管式交易所。目前的主流去中心化交易所，主要有三大特征：

- 去中心化运行：应用的运行不依赖于中心化服务器的服务；或者即使所依赖的中心化服务器宕机，应用的核心数据和服务也不会收到影响。

- 不托管用户资产：用户无需向应用本身或者第三方托管资产，就可以获得完整的交易服务。

- 无审核服务：应用不会对特定用户拒绝服务，也不会限制用户交易任何种类的资产。

## 自动化做市商(AMM)

在传统的中心化交易所当中，有专门的市商在交易所中挂买卖单，以提供资产流动性。同样，在去中心化交易所，也需要有人为资产提供流动性。然而，不同于中心化交易所挂单成本几乎为0，在区块链上进行频繁的挂单、撤单操作会消耗大量手续费，而且并不及时，这会导致市商的严重亏损。因此，去中心化交易所必需要开发出一套能在区块链上运行的自动化做市商系统，能够为提供流动性的市商自动地配置买卖双边资产，减少损失。

## 恒定乘积做市模型(CPMM)

Uniswap-v2 使用了恒定乘积做市模型来实现自动化做市商。其计算步骤如下：

1. 甲在 Uniswap-v2 上提供了 1000 个 TokenA 和 100 个 TokenB 作为流动池，计乘数 Kab = 1000 * 100 = 100000
2. 乙想要在 Uniswap-v2 上使用 1000 个 TokenA 兑换 TokenB，那么 Uniswap-v2 会首先计算交易后流动池会有 1000 + 1000 = 2000 个 TokenA；为了维持 Kab 的不变，就需要 TokenB 的数量减少为 100000/2000 = 50 。因此，Uniswap-v2 会给乙兑换出100 - 50 = 50 个 TokenB 。
3. 乙成功地使用 1000 个 TokenA 在 Uniswap-v2 上兑换了 50 个 TokenB。可以预见的是，根据这套算法，乙需要兑换的 TokenA 越多，平均每个 TokenA 能兑换的 TokenB 就会越少。这就产生了滑点的概念。

简化公式：(TokenA余额 + 你出售的TokenA)*(TokenB余额 - 你获得的TokenB) = 常数K

## 滑点

在上面的例子中，甲在 Uniswap-v2 上提供了 1000 个 TokenA 和 100 个 TokenB 作为流动池，TokenA 和 TokenB 的标记比价为 10：1，即10个 TokenA 可以兑换 1 个 TokenB。然而在乙使用 1000 个 TokenA 在 Uniswap-v2 上兑换了 50 个 TokenB之后，其实际的交易比价约为 1000：50，实际上使用 10 个 TokenA 只能兑换 0.5 个 TokenB。这就是在 Uniswap-v2 上交易产生了滑点，滑点高达 50% 。

## 流动池

不同于传统中心化交易所的订单交易，可以理解为有一个和你博弈的对手，你需要买入他卖出的单子，或者等他吃掉你卖出的单子。不管买入还是卖出，在 Uniswap-v2 上的所有交易都是对流动池的交易，没有对手会直接和你做交易。

## 流动性凭证(LP)

当你在 Uniswap-v2 上为代币提供流动性时，Uniswap-v2 会发送给你一个流动性凭证(LP)，这代表了你对你所提供流动性的所有权。要从流动池中提取资产时，必需要返回流动性凭证。因此千万不要随意转移LP到不受你控制的地址（本人血泪教训）。

## 无常损失

当你在 Uniswap-v2 上为代币提供流动性，赚取手续费时，会涉及到无常损失的计算。下面举一个简单的例子。

1. 甲在 Uniswap-v2 上提供了 1000 个 TokenA 和 100 个 usdt 作为流动池，乙在 Uniswap-v2 上使用 1000 个 TokenA 兑换了 50 个 usdt，池子里剩下 2000 个 TokenA 和 50 个 usdt。

2. 原来甲在 Uniswap-v2 上提供的总资产价值为  1000 个 TokenA 和 100 个 usdt，TokenA 对 usdt 的兑换比率为 1000 ：100，可以换算为 200 个 usdt。乙兑换之后，甲在 Uniswap-v2 上提供的流动性资产价值为：2000 个 TokenA 和 50 个 usdt，TokenA 对 usdt 的兑换比率为 2000：50 ，总计为 100 个 usdt。

4. 而如果甲本来就不提供流动性，TokenA 对 usdt 的兑换比率跌为2000：50 ，则其资产为 1000 个 TokenA 和  100 个 usdt = 125 usdt。可以看到，甲因为提供流动性多损失了25usdt，这就是资产下跌造成的无常损失。

5. 乙改为在 Uniswap-v2 上使用 100 个 usdt 兑换了 500 个 TokenA。乙兑换之后，甲在 Uniswap-v2 上提供的流动性资产价值为：500 个 TokenA 和 200 个 usdt，TokenA 对 usdt 的兑换比率为 500：200，总计为 400 个 usdt。

6.  而如果甲本来就不提供流动性，TokenA 对 usdt 的兑换比率涨到500：200，则其资产为 1000 个 TokenA 和  100 个 usdt = 500 usdt。可以看到，甲因为提供流动性少赚了100usdt，这就是资产上涨造成的无常损失。

简单总结：无常损失就是流动性提供者，在资产上涨过程中自动卖出，在资产下跌过程中自动买入所造成的损失。

## 闪电贷

闪电贷是一种新型的无抵押贷款，目前只能在区块链上实现，uniswap-v2 也完成了闪电贷的实现。其主要特点：

- 使用闪电贷借出的资产无需任何抵押品，也不要任何身份认证，但必须在借出的同一个区块内完成还款并支付利息，否则借款就会失败并回滚交易数据。

目前来说，闪电贷的主要用途是借贷平仓、交易所搬砖、黑客攻击等。很多被黑客攻击的受害者认为闪电贷是一种危险的工具，不应该存在。但不管怎么说，它赋予了所有人用极小成本，使用极大资金的能力。

## 价格预言机

Uniswap-v2 所代表的去中心化交易所，提供去中心化的价格生成体系。以此为基础，可以打造出一个去中心化的价格生成和获取系统。这对于去中心化的借贷、杠杆等金融衍生品来说非常重要，虽然目前 Uniswap-v2 所代表的去中心化单一流动池价格预言机并不是完全安全的。

