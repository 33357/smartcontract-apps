# Uniswap Universal Router 之 Permit2 合约分析

## 备注

时间：2023 年 5 月 2 日

作者：[33357](https://github.com/33357)

## 事件概要

Uniswap 发布了最新的 Universal Router 合约，之后长期占据 Gas 排行榜第一。Universal Router 合约的新功能很多，但对 Uniswap 上用户来说最大的区别就是集成了 Permit2 合约。该合约支持使用签名而不是交易来完成代币的转账授权，并且支持传统的 ERC20 合约。Permit2 合约的方法支持第三方调用，又有以太坊上最大 DEX 的支持，可能会成为以太坊生态中重要的基础设施。

[github 地址](https://github.com/33357/permit2)

[合约地址](https://etherscan.io/address/0x000000000022d473030f116ddee9f6b43ac78ba3/advanced#code)

## 合约分析

### [Permit2.sol](https://github.com/33357/permit2/blob/main/src/Permit2.sol)
- Permit2 合约继承了 SignatureTransfer 和 AllowanceTransfer，只要研究这两个合约就能明白 Permit2 的功能和逻辑。

### [SignatureTransfer.sol](https://github.com/33357/permit2/blob/main/src/SignatureTransfer.sol)

#### 授权转账
- 外部函数（仅合约外部可以调用）
    - permitTransferFrom
        - 分析
            ```javascript
            struct TokenPermissions {
                address token; // token 地址
                uint256 amount; // 授权数量
            }
            struct PermitTransferFrom {
                TokenPermissions permitted; // token 授权
                uint256 nonce; // 无序 nonce
                uint256 deadline; // 截止时间
            }
            struct SignatureTransferDetails {
                address to; // 接收地址
                uint256 requestedAmount; // 请求数量
            }
            function permitTransferFrom(
                PermitTransferFrom memory permit, // 交易授权
                SignatureTransferDetails calldata transferDetails, // transfer 请求
                address owner, // owner
                bytes calldata signature// 签名
            ) external {
                // 调用内部实现函数
                _permitTransferFrom(permit, transferDetails, owner, permit.hash(), signature);
            }
            ```
        - 小结

            permitTransferFrom 允许合约使用 owner 的单个 Token 签名授权进行转账。
    - permitTransferFrom（批量）
        - 分析
            ```javascript
            struct TokenPermissions {
                address token; // token 地址
                uint256 amount; // 授权数量
            }
            struct PermitBatchTransferFrom {
                TokenPermissions[] permitted; // token 授权列表
                uint256 nonce; // 无序 nonce
                uint256 deadline; // 截止时间
            }
            struct SignatureTransferDetails {
                address to; // 接收地址
                uint256 requestedAmount; // 请求数量
            }
            function permitTransferFrom(
                PermitBatchTransferFrom memory permit, // 批量 transfer 授权
                SignatureTransferDetails[] calldata transferDetails, // transfer 请求列表
                address owner, // owner
                bytes calldata signature// 签名
            ) external {
                // 调用内部实现函数
                _permitTransferFrom(permit, transferDetails, owner, permit.hash(), signature);
            }
            ```
        - 小结

        permitTransferFrom（批量）允许合约使用 onwer 的多个 Token 签名授权进行批量转账。
- 内部函数（仅合约内部可以调用）
    - _permitTransferFrom
        - 分析
            ```javascript
            function _permitTransferFrom(
                PermitTransferFrom memory permit, // transfer 授权
                SignatureTransferDetails calldata transferDetails, // transfer 请求
                address owner, // owner
                bytes32 dataHash, // 数据 hash
                bytes calldata signature // 签名
            ) private {
                uint256 requestedAmount = transferDetails.requestedAmount;
                // 检查 “截止时间” 是否已过
                if (block.timestamp > permit.deadline) revert SignatureExpired(permit.deadline);
                // 检查 “请求数量” 是否大于 “授权数量”
                if (requestedAmount > permit.permitted.amount) revert InvalidAmount(permit.permitted.amount);
                // 检查 “owner” 的 “无序 nonce” 是否被使用过
                _useUnorderedNonce(owner, permit.nonce);
                // 使用 “数据 hash” 验证 “签名” 所有者是否是 “owner”
                signature.verify(_hashTypedData(dataHash), owner);
                // 将 “请求数量” 的 token 从 “owner” 转到 “接收地址”
                ERC20(permit.permitted.token).safeTransferFrom(owner, transferDetails.to, requestedAmount);
            }
            ```
        - 小结

        _permitTransferFrom 实现了对 “签名”、“nonce”、“过期时间” 和 “请求数量” 的验证，可将 “请求数量” 的 token 从 “owner” 转到 “接收地址”。
    - _permitTransferFrom（批量）
        - 分析
            ```javascript
            function _permitTransferFrom(
                PermitBatchTransferFrom memory permit, // transfer 授权
                SignatureTransferDetails[] calldata transferDetails, // transfer 请求列表
                address owner, // owner
                bytes32 dataHash, // 数据 hash
                bytes calldata signature // 签名
            ) private {
                uint256 numPermitted = permit.permitted.length;
                // 检查 “截止时间” 是否已过
                if (block.timestamp > permit.deadline) revert SignatureExpired(permit.deadline);
                // 检查 “token 授权列表” 是否和 “transfer 请求列表” 长度一致
                if (numPermitted != transferDetails.length) revert LengthMismatch();
                // 检查 “owner” 的 “无序 nonce” 是否被使用过
                _useUnorderedNonce(owner, permit.nonce);
                // 使用 “数据 hash” 验证 “签名” 所有者是否是 “owner”
                signature.verify(_hashTypedData(dataHash), owner);
                unchecked {
                    for (uint256 i = 0; i < numPermitted; ++i) {
                        TokenPermissions memory permitted = permit.permitted[i];
                        uint256 requestedAmount = transferDetails[i].requestedAmount;
                        // 检查 “请求数量” 是否大于 “授权数量”
                        if (requestedAmount > permitted.amount) revert InvalidAmount(permitted.amount);
                        if (requestedAmount != 0) {
                            // 将 “请求数量” 的 token 从 “owner” 转到 “接收地址”
                            ERC20(permitted.token).safeTransferFrom(owner, transferDetails[i].to, requestedAmount);
                        }
                    }
                }
            }
            ```
        - 小结

        _permitTransferFrom（批量） 实现了对 “签名”、“nonce”、“过期时间” 和 “请求数量” 的验证，可批量将 “请求数量” 的 token 从 “owner” 转到 “接收地址”。

#### 见证授权转账
- 外部函数（仅合约外部可以调用）
    - permitWitnessTransferFrom
        - 分析
            ```javascript
            struct TokenPermissions {
                address token; // token 地址
                uint256 amount; // 授权数量
            }
            struct PermitTransferFrom {
                TokenPermissions permitted; // token 授权
                uint256 nonce; // 交易 nonce
                uint256 deadline; // 截止时间
            }
            struct SignatureTransferDetails {
                address to; // 接收地址
                uint256 requestedAmount; // 请求数量
            }
            function permitWitnessTransferFrom(
                PermitTransferFrom memory permit, // 交易授权
                SignatureTransferDetails calldata transferDetails, // transfer 请求
                bytes32 witness, // 见证数据 hash
                string calldata witnessTypeString, // 见证数据类型
                address owner, // owner
                bytes calldata signature// 签名
            ) external {
                // 调用内部实现函数
                _permitTransferFrom(permit, transferDetails, owner, permit.hashWithWitness(witness, witnessTypeString), signature);
            }
            ```
        - 小结

        permitWitnessTransferFrom 使用时需要添加额外的 “见证数据 hash” 和 “见证数据类型”，以完成额外数据签名的验证功能。
    - permitWitnessTransferFrom（批量）
        - 分析
            ```javascript
            struct TokenPermissions {
                address token; // token 地址
                uint256 amount; // 授权数量
            }
            struct PermitBatchTransferFrom {
                TokenPermissions[] permitted; // token 授权列表
                uint256 nonce; // 交易 nonce
                uint256 deadline; // 截止时间
            }
            struct SignatureTransferDetails {
                address to; // 接收地址
                uint256 requestedAmount; // 请求数量
            }
            function permitWitnessTransferFrom(
                PermitBatchTransferFrom memory permit, // 批量 transfer 授权
                SignatureTransferDetails[] calldata transferDetails, // transfer 请求列表
                bytes32 witness, // 见证数据 hash
                string calldata witnessTypeString, // 见证数据类型
                address owner, // owner
                bytes calldata signature// 签名
            ) external {
                // 调用内部实现函数
                _permitTransferFrom(permit, transferDetails, owner, permit.hashWithWitness(witness, witnessTypeString), signature);
            }
            ```
        - 小结

            permitWitnessTransferFrom（批量）使用时需要添加额外的 “见证数据 hash” 和 “见证数据类型”，以完成额外数据签名的验证功能。

#### 无序 nonce 验证
- 内部函数（仅合约内部可以调用）
    - _useUnorderedNonce
        - 分析
            ```javascript
            function _useUnorderedNonce(
                address from, // 授权者
                uint256 nonce // 无序 nonce
            ) internal {
                // 获取字位置和位位置
                (uint256 wordPos, uint256 bitPos) = bitmapPositions(nonce);
                // 不懂，请大佬解释
                uint256 bit = 1 << bitPos;
                // 不懂，请大佬解释
                uint256 flipped = nonceBitmap[from][wordPos] ^= bit;
                // 不懂，请大佬解释
                if (flipped & bit == 0) revert InvalidNonce();
            }
            ```
        - 小结

        _useUnorderedNonce 可以检查 “授权者” 的 “无序 nonce” 是否已经用过。
- 外部函数（仅合约外部可以调用）
    - bitmapPositions
        - 分析
            ```javascript
            function bitmapPositions(
                uint256 nonce // 无序 nonce
            ) private pure returns (
                uint256 wordPos, // 字位置
                uint256 bitPos // 位位置
            ) {
                // 获取无序 nonce 前 248 位
                wordPos = uint248(nonce >> 8);
                // 获取无序 nonce 后 8 位
                bitPos = uint8(nonce);
            }
            ```
        - 小结

            bitmapPositions 将 nonce 的前 248 位和后 8 位分开并返回。

#### 设置无序 nonce
- 内部函数（仅合约内部可以调用）
    - invalidateUnorderedNonces
        - 分析
            ```javascript
            function invalidateUnorderedNonces(
                uint256 wordPos, // 字位置
                uint256 mask // 不懂，请大佬解释
            ) external {
                // 不懂，请大佬解释
                nonceBitmap[msg.sender][wordPos] |= mask;
                emit UnorderedNonceInvalidation(msg.sender, wordPos, mask);
            }
            ```
        - 小结

        invalidateUnorderedNonces 设置新的 “无序 nonce”。

### [AllowanceTransfer.sol](https://github.com/33357/permit2/blob/main/src/AllowanceTransfer.sol)

#### 授权
- 外部函数（仅合约外部可以调用）
    - approve
        - 分析
            ```javascript
            function approve(
                address token, // token 地址
                address spender, // 被授权地址
                uint160 amount, // 授权数量
                uint48 expiration // 过期时间
            ) external {
                PackedAllowance storage allowed = allowance[msg.sender][token][spender];
                // 更新 “授权数量” 和 “过期时间”
                allowed.updateAmountAndExpiration(amount, expiration);
                emit Approval(msg.sender, token, spender, amount, expiration);
            }
            ```
        - 小结

            approve 可以直接调用来更新 msg.sender 对 “被授权地址” 的 “授权数量” 和 “过期时间”。

#### 签名授权
- 外部函数（仅合约外部可以调用）
    - permit
        - 分析
            ```javascript
            struct PermitDetails {
                address token; // token 地址
                uint160 amount; // 授权数量
                uint48 expiration; // 过期时间
                uint48 nonce; // nonce
            }
            struct PermitSingle {
                PermitDetails details; // 授权数据
                address spender; // 发送者
                uint256 sigDeadline; // 签名过期时间
            }
            function permit(
                address owner, // owner
                PermitSingle memory permitSingle, // 单笔授权数据
                bytes calldata signature // 签名
            ) external {
                // 检查 “签名过期时间” 是否已过
                if (block.timestamp > permitSingle.sigDeadline) revert SignatureExpired(permitSingle.sigDeadline);
                // 使用 “单笔授权数据“ hash 验证 “签名” 所有者是否是 “owner”
                signature.verify(_hashTypedData(permitSingle.hash()), owner);
                // 调用内部更新授权函数
                _updateApproval(permitSingle.details, owner, permitSingle.spender);
            }
            ```
        - 小结

            permit 可以使用签名完成单个 token 的转账授权。
    - permit（批量）
        - 分析
            ```javascript
            function permit(
                address owner, // owner
                PermitBatch memory permitBatch, // 批量授权数据
                bytes calldata signature // 签名
            ) external {
                // 检查 “签名过期时间” 是否已过
                if (block.timestamp > permitBatch.sigDeadline) revert SignatureExpired(permitBatch.sigDeadline);
                // 使用 “批量授权数据“ hash 验证 “签名” 所有者是否是 “owner”
                signature.verify(_hashTypedData(permitBatch.hash()), owner);
                address spender = permitBatch.spender;
                unchecked {
                    uint256 length = permitBatch.details.length;
                    for (uint256 i = 0; i < length; ++i) {
                        // 调用内部更新授权函数
                        _updateApproval(permitBatch.details[i], owner, spender);
                    }
                }
            }
            ```
        - 小结

            permit（批量）可以使用签名完成批量 token 的转账授权。
- 内部函数（仅合约内部可以调用）
    - _updateApproval
        - 分析
            ```javascript
            struct PermitDetails {
                address token; // token 地址
                uint160 amount; // 授权数量
                uint48 expiration; // 过期时间
                uint48 nonce; // nonce
            }
            function _updateApproval(
                PermitDetails memory details, // 授权数据
                address owner,  // 授权者
                address spender // 被授权者
            ) private {
                uint48 nonce = details.nonce;
                address token = details.token;
                uint160 amount = details.amount;
                uint48 expiration = details.expiration;
                PackedAllowance storage allowed = allowance[owner][token][spender];
                // 检查 nonce 和要求的是否一致
                if (allowed.nonce != nonce) revert InvalidNonce();
                // 更新 “授权数量”、“过期时间” 和 “nonce”
                allowed.updateAll(amount, expiration, nonce);
                emit Permit(owner, token, spender, amount, expiration, nonce);
            }
            ```
        - 小结

            _updateApproval 实现了对 “nonce” 的验证，更新了 “授权者” 对 “被授权地址” 的 token “授权数量”、“过期时间” 和 “nonce”。

#### 转账
- 外部函数（仅合约外部可以调用）
    - transferFrom
        - 分析
            ```javascript
            function transferFrom(
                address from, // 发送地址
                address to, // 接收地址
                uint160 amount, // 转账数量
                address token // token 地址
            ) external {
                // 调用内部转账函数
                _transfer(from, to, amount, token);
            }
            ```
        - 小结

            transferFrom 可以完成单笔转账。
    - transferFrom（批量）
        - 分析
            ```javascript
            struct AllowanceTransferDetails {
                address from, // 发送地址
                address to, // 接收地址
                uint160 amount, // 转账数量
                address token // token 地址
            }
            function transferFrom(
                AllowanceTransferDetails[] calldata transferDetails // 转账数据列表
            ) external {
                unchecked {
                    uint256 length = transferDetails.length;
                    for (uint256 i = 0; i < length; ++i) {
                        AllowanceTransferDetails memory transferDetail = transferDetails[i];
                        // 调用内部转账函数
                        _transfer(transferDetail.from, transferDetail.to, transferDetail.amount, transferDetail.token);
                    }
                }
            }
            ```
        - 小结

            transferFrom（批量）可以完成单笔转账。
- 内部函数（仅合约内部可以调用）
    - _transfer
        - 分析
            ```javascript
            function _transfer(
                address from, // 发送地址
                address to, // 接收地址
                uint160 amount, // 转账数量
                address token // token 地址
            ) private {
                PackedAllowance storage allowed = allowance[from][token][msg.sender];
                // 检查转账授权是否过期
                if (block.timestamp > allowed.expiration) revert AllowanceExpired(allowed.expiration);
                uint256 maxAmount = allowed.amount;
                // 如果最大授权数量等于 type(uint160).max，则不更新授权数量
                if (maxAmount != type(uint160).max) {
                    // 如果最大授权数量小于 “转账数量”，就抛出错误
                    if (amount > maxAmount) {
                        revert InsufficientAllowance(maxAmount);
                    } else {
                        unchecked {
                            // 授权数量减去 “转账数量”
                            allowed.amount = uint160(maxAmount) - amount;
                        }
                    }
                }
                // 将 “转账数量” 的 token 从 “发送地址” 发送到 “接收地址”
                ERC20(token).safeTransferFrom(from, to, amount);
            }
            ```
        - 小结

        _transfer 实现了对 “过期时间” 和 “转账数量” 的验证，可将 “转账数量” 的 token 从 “发送地址” 转到 “接收地址”。

#### 锁定授权
- 外部函数（仅合约外部可以调用）
    - lockdown
        - 分析
            ```javascript
            struct TokenSpenderPair {
                address token; // 授权 token
                address spender; // 授权者
            }
            function lockdown(TokenSpenderPair[] calldata approvals) external {
                address owner = msg.sender;
                unchecked {
                    uint256 length = approvals.length;
                    for (uint256 i = 0; i < length; ++i) {
                        address token = approvals[i].token;
                        address spender = approvals[i].spender;
                        // “授权数量” 重置为 0
                        allowance[owner][token][spender].amount = 0;
                        emit Lockdown(owner, token, spender);
                    }
                }
            }
            ```
        - 小结

            lockdown 通过将 “授权数量” 重置为 0 来锁定授权。

#### 设置 nonce
- 外部函数（仅合约外部可以调用）
    - invalidateNonces
        - 分析
            ```javascript
            function invalidateNonces(
                address token, // 授权 token
                address spender, // 被授权者
                uint48 newNonce // 新 nonce
            ) external {
                uint48 oldNonce = allowance[msg.sender][token][spender].nonce;
                // “新 nonce” 需要大于 nonce
                if (newNonce <= oldNonce) revert InvalidNonce();
                unchecked {
                    uint48 delta = newNonce - oldNonce;
                    // “新 nonce” 和 nonce 的差值不能大于 type(uint16).max
                    if (delta > type(uint16).max) revert ExcessiveInvalidation();
                }
                // nonce 设置成 “新 nonce”
                allowance[msg.sender][token][spender].nonce = newNonce;
                emit NonceInvalidation(msg.sender, token, spender, newNonce, oldNonce);
            }
            ```
        - 小结

            invalidateNonces 可以设置 “新 nonce”。

## 总结

Permit2 支持 SignatureTransfer 和 AllowanceTransfer，既可以让用户使用签名授权转账也可以让用户使用交易授权后再转账，功能强大的同时也兼容了传统的 ERC20 协议的 token。不过需要注意的是使用 permitTransferFrom 要防止签名被盗用，合约设计者需要考虑这个问题。