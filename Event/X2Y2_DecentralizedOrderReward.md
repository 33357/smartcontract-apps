# X2Y2: 必须修改的中心化NFT挂单奖励机制

## X2Y2 的爆发与沉没

2022年2月15日，X2Y2 正式开启空投、NFT挂单奖励和质押挖矿，随后的十几天内其币价一泻千里。最低到0.25 u/X2Y2，相比最高点跌了90%以上。直到官方宣布修改NFT挂单奖励，大幅减少产出，币价才重新稳定在0.35 u/X2Y2左右。

## 中心化 NFT 挂单奖励是不可持续的

X2Y2 币价的下跌是多重因素的共同作用，其相比 OpenSea 新创的交易手续费返还 X2Y2 持有者和 NFT 挂单奖励是具有相当程度先进性的。但是我认为：中心化、不透明、无法预测的 NFT 挂单奖励机制在区块链乃至整个 Web3 世界都是不可持续的，主要问题有以下几点：

- NFT挂单奖励算法会被随意修改，用户无法做长期决策（之前团队为了稳定币价修改算法的决策值得肯定，但严重削弱了挂单用户对项目的信任）。

- 用户无法对挂单奖励进行预测，因此无法对是否挂单做理性决策（具体来说就是无法在挂单之前对挂单奖励做预测，这会导致很多人要么抱着赌一把的心态来挂单，要么抱着不信任的态度走人）。

- 团队有持币跑路的风险（区块链世界里代码才是法律，甚至高于法律，达到了物理规则的高度。团队跑路的成本和收益相比不值一提，因此永远不要高估人性）。

之前我在项目方群里讨论这个问题时，有很多人认为 NFT 挂单奖励对 NFT 挂单者是一种 “恩惠”，而不是一种商业模式：你在 OpenSea 挂单啥都没有，来这里还有可能获得奖励，因此中心化的 NFT 挂单奖励机制的这些弊病是没有问题的。我觉得如果真是这样，那么这个项目就不足以对 OpenSea 在商业模式上进行创新，而大多数用户没有足够多确定的利益是懒得去换平台的。

## 如何设计去中心化的 NFT 挂单奖励

这是一个区块链技术方向的社群，因此讨论不会仅涉及于提出问题而没有解决方案。在去中心化的代币奖励方面，早有前人为我们指明了一条道路，那就是目前普遍用于代币质押的挖矿奖励算法（篇幅所限，我就不去解释这个算法了）。我们只需要知道，这个算法实现了随时间和质押代币数量成正比的奖励。在个条件下，时间是不需要改变的，而 NFT 不是代币。因此只要实现从 NFT 到代币的转换，就完全可以实现去中心化的 NFT 挂单奖励。

- 这是一个简单的算法，使用挂单价格作为唯一参数，实现从 NFT 到代币的转换
    ``` javascript
    // 最大价格
    uint256 constant MAX_PRICE = 10**26;
    // 最小价格
    uint256 constant MIN_PRICE = 10**10;
    // 预估分数
    function predictPoint(uint256 price) public pure override returns (uint256) {
        // 价格不能超过范围
        require(price <= MAX_PRICE && price >= MIN_PRICE, "NFT: price is too high or too low");
        // 计算分数
        return (MAX_PRICE * MIN_PRICE) / price;
    }
    ```
    在这里，我把从 NFT 到代币的转换过程抽象为给每个 NFT 打分的过程。NFT 作为非同质化代币，想要准确地给每个 NFT 打分，只有从挂单价格入手：价格越高的 NFT 其分数越低。
    
    - 在这里我们可以演算一下：如果一共有10个 NFT，其价格分别是 1、2、3、4、5、6、7、8、9、10 ETH，那么打分的情况会是什么？
        - point1: `(10**26 * 10**10) / 10**18 = 10**18`
        - point2: `(10**26 * 10**10) / (2 * 10**18) = 10**18 / 2`
        - point3: `(10**26 * 10**10) / (3 * 10**18) = 10**18 / 3`
        - point4: `(10**26 * 10**10) / (4 * 10**18) = 10**18 / 4`
        - point5: `(10**26 * 10**10) / (5 * 10**18) = 10**18 / 5`
        - point6: `(10**26 * 10**10) / (6 * 10**18) = 10**18 / 6`
        - point7: `(10**26 * 10**10) / (7 * 10**18) = 10**18 / 7`
        - point8: `(10**26 * 10**10) / (8 * 10**18) = 10**18 / 8`
        - point9: `(10**26 * 10**10) / (9 * 10**18) = 10**18 / 9`
        - point10: `(10**26 * 10**10) / (10 * 10**18) = 10**18 / 10`

        point 总数为 `10**18 * (7381/2520)`，每个 NFT 代币可以分到奖励的份额如下：
        - token1: `2520/7381`
        - token2: `1260/7381`
        - token3: `840/7381`
        - token4: `630/7381`
        - token5: `504/7381`
        - token6: `420/7381`
        - token7: `360/7381`
        - token8: `315/7381`
        - token9: `280/7381`
        - token10: `252/7381`

        可以看到，随着 NFT 挂单价格的升高，其分数会下降，奖励份额也会下降。

        一般而言NFT的挂单价格不会如此平均，一般会呈现中间多，两头少的“橄榄球”形状，这意味着挂单价格低的用户会拥有比这个演算更多的奖励。

- 对于不同类型的NFT，需要给予不同的挂单奖励。

    由于不同类型的 NFT 之间价格差异巨大，因此不可能对所有种类的 NFT 给予相同的奖励池。实际上每种 NFT 的奖励池额度需要单独计算，对此又可以衍生出好几种不同的算法：

    - 使用中心化的算法

        实际上目前 X2Y2 就是使用的这种算法，其效果只能说是差强人意。

    - 使用去中心化的算法

        可以使用每种 NFT 的交易手续费作为参数，对奖励额度在链上进行动态调整。我预计是可行的，但是在没有手续费时，项目如何启动是一个问题。

    - 使用 DAO 进行管理

        对上述的方案进行中和，使用 DAO 让社区成员投票决定给某种 NFT 多少奖励池。这种方案依赖良好的社群用户。

- 对挂单奖励进行预测

    经典的挖矿奖励算法已经实现了对奖励的预测，还可以计算 APY。由于 NFT 难确定标准的市场价格，因此我估计只能在用户输入挂单价格后，预测每天获得多少奖励。

- 对挂买单进行奖励

    实际上对上述的挂单 NFT 奖励算法反过来，就可以对挂 NFT 买单进行奖励。也许可以借此做出一个 NFT 的公允市场价。


- 目前的问题

    - 这套方案里挂单需要上链，改价格也需要上链，因此和 OpenSea 目前的模式并不完全兼容。

    - 挂单需要将 NFT 的所有权转移到合约，因此不能同时挂在 OpenSea 上。

## 总结

X2Y2 在 OpenSea 的基础上进行了创新，却无法给 OpenSea 用户足够的利益让他们改换门庭。但无论如何，OpenSea 再不改革把自己的利益分享出来，下个四年就看不到它的身影了。

- 目前实现的代码，有很多问题，并不完善
    ```  javascript
    //SPDX-License-Identifier: Unlicense
    pragma solidity ^0.8.12;

    import "./interfaces/INFT.sol";
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    contract NFT is INFT, ReentrancyGuard {
        using SafeERC20 for IERC20;

        mapping(address => uint256) blockMint;

        mapping(address => uint256) totalPoint;

        mapping(address => uint256) perPointMinted;

        mapping(address => uint256) lastUpdateBlock;

        mapping(address => mapping(uint256 => uint256)) tokenPoint;

        mapping(address => mapping(uint256 => address)) tokenOwner;

        mapping(address => mapping(uint256 => uint256)) tokenPrice;

        mapping(address => mapping(uint256 => uint256)) tokenMinted;

        mapping(address => mapping(uint256 => uint256)) tokenPerPointPaid;

        uint256 constant MAX_PRICE = 10**26;

        uint256 constant MIN_PRICE = 10**10;

        uint256 fee = 200;

        address feeTo;

        constructor() {}

        /* ================ UTIL FUNCTIONS ================ */

        function safeTransferETH(address to, uint256 value) internal {
            (bool success, ) = to.call{value: value}(new bytes(0));
            require(success, "NFT: ETH transfer failed");
        }

        function perPointMint(address nft) internal view returns (uint256) {
            if (totalPoint[nft] != 0) {
                return perPointMinted[nft] + ((block.number - lastUpdateBlock[nft]) * blockMint[nft]) / totalPoint[nft];
            } else {
                return perPointMinted[nft];
            }
        }

        modifier _updateMint(address nft, uint256 tokenId) {
            if (block.number > lastUpdateBlock[nft]) {
                perPointMinted[nft] = perPointMint(nft);
                lastUpdateBlock[nft] = block.number;
            }
            if (totalPoint[nft] != 0) {
                tokenMinted[nft][tokenId] = tokenMint(nft, tokenId);
            }
            tokenPerPointPaid[nft][tokenId] = perPointMinted[nft];
            _;
        }

        /* ================ VIEW FUNCTIONS ================ */

        function predictPoint(uint256 price) public pure override returns (uint256) {
            require(price <= MAX_PRICE && price >= MIN_PRICE, "NFT: price is too high or too low");
            return (MAX_PRICE * MIN_PRICE) / price;
        }

        function tokenMint(address nft, uint256 tokenId) public view override returns (uint256) {
            return
                tokenMinted[nft][tokenId] +
                (tokenPoint[nft][tokenId] * (perPointMint(nft) - tokenPerPointPaid[nft][tokenId]));
        }

        /* ================ TRANSACTION FUNCTIONS ================ */

        function list(
            address nft,
            uint256 tokenId,
            uint256 price
        ) external override nonReentrant {
            tokenPoint[nft][tokenId] = predictPoint(price);
            totalPoint[nft] += tokenPoint[nft][tokenId];
            tokenPrice[nft][tokenId] = price;
            tokenOwner[nft][tokenId] = msg.sender;
            IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        }

        function unList(address nft, uint256 tokenId) external override nonReentrant {
            require(tokenOwner[nft][tokenId] == msg.sender, "NFT: sender not owner");
            require(IERC721(nft).ownerOf(tokenId) == address(this), "NFT: this not owner");
            totalPoint[nft] -= tokenPoint[nft][tokenId];
            tokenPoint[nft][tokenId] = 0;
            tokenOwner[nft][tokenId] = address(0);
            tokenPrice[nft][tokenId] = 0;
            IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
        }

        function rePrice(
            address nft,
            uint256 tokenId,
            uint256 price
        ) external override nonReentrant {
            require(tokenOwner[nft][tokenId] == msg.sender, "NFT: sender not owner");
            require(IERC721(nft).ownerOf(tokenId) == address(this), "NFT: this not owner");
            totalPoint[nft] -= tokenPoint[nft][tokenId];
            tokenPoint[nft][tokenId] = predictPoint(price);
            totalPoint[nft] += tokenPoint[nft][tokenId];
            tokenPrice[nft][tokenId] = price;
        }

        function buy(address nft, uint256 tokenId) external payable override nonReentrant {
            require(msg.value >= tokenPrice[nft][tokenId], "NFT: price is too low");
            require(IERC721(nft).ownerOf(tokenId) == address(this), "NFT: this not owner");
            uint256 feeAmount = (tokenPrice[nft][tokenId] * fee) / 10000;
            totalPoint[nft] -= tokenPoint[nft][tokenId];
            tokenPoint[nft][tokenId] = 0;
            tokenOwner[nft][tokenId] = address(0);
            safeTransferETH(feeTo, feeAmount);
            safeTransferETH(tokenOwner[nft][tokenId], tokenPrice[nft][tokenId] - feeAmount);
            tokenPrice[nft][tokenId] = 0;
            IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
            if (address(this).balance > 0) {
                safeTransferETH(msg.sender, address(this).balance);
            }
        }

        /* ================ ADMIN FUNCTIONS ================ */

        function setBlockMint(address nft, uint256 newBlockMint) external {
            blockMint[nft] = newBlockMint;
        }

        function setFee(uint256 newFee) external {
            fee = newFee;
        }

        function setFeeTo(address newFeeTo) external {
            feeTo = newFeeTo;
        }
    }

    ```



