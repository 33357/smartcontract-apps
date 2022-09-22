# 最省GAS链上排序

## 原理

因为区块链机制的限制，智能合约的执行步骤越多，消耗的GAS也越多。传统的排序算法需要对数组进行遍历从而实现排序，这种操作消耗的GAS会随着数组长度成正比上涨。为了在链上实现排序并尽可能地减少GAS消耗，我们需要把计算量放到链下，把验证放到链上，从而实现既安全又节约GAS的链上排序功能。

## 实现
``` javascript
uint256 public firstSortId;
uint256 public sortLength;
mapping(uint256 => uint256) private _sortMap;

function _addSort(
    uint256 beforeSortId,
    uint256 id
) internal {
    if (beforeSortId == 0) {
        if (firstSortId != 0) {
            require(
                firstSortId <= id,
                "Sort: sort error"
            );
        }
        _sortMap[id] = firstSortId;
        firstSortId = id;
    } else if (_sortMap[beforeSortId] == 0) {
        require(
            firstSortId >= id,
            "Sort: sort error"
        );
        _sortMap[beforeSortId] = id;
    } else {
        require(
            beforeSortId >= id &&
                _sortMap[beforeSortId] <= id &&
                beforeSortId !=
                _sortMap[beforeSortId],
            "Sort: sort error"
        );
        _sortMap[_sortMap[id]] = _sortMap[beforeSortId];
        _sortMap[beforeSortId] = id;
    }
    sortLength++;
}

function _removeSort(
    uint256 beforeSortId,
    uint256 id
) internal {
    if (beforeSortId == 0) {
        require(firstSortId == id, "Sort: sort error");
        firstSortId = _sortMap[firstSortId];
    } else {
        require(
            _sortMap[beforeSortId] == id,
            "Sort: sort error"
        );
        _sortMap[beforeSortId] = _sortMap[id];
    }
    sortLength--;
}

function getIdListBySort(uint256 startId, uint256 length)
    public
    view
    returns (uint256[] memory)
{
    uint256[] memory idList = new uint256[](length);
    uint48 id = startId;
    for (uint256 i = 0; i < length; i++) {
        id = _sortMap[id];
        idList[i] = id;
    }
    return idList;
}
```

## 解析

- 公共函数（合约内外部都可以调用）
    - getIdListBySort
        - 代码速览
            ``` javascript
            function getIdListBySort(uint256 startId, uint256 length)
                public
                view
                returns (uint256[] memory)
            {
                uint256[] memory idList = new uint256[](length);
                uint48 id = startId;
                for (uint256 i = 0; i < length; i++) {
                    id = _sortMap[id];
                    idList[i] = id;
                }
                return idList;
            }
            ```
        - 参数分析
            函数 `getIdListBySort` 的入参有 2 个，出参有 0 个，对应的解释如下：
            ``` javascript
            constructor(
                uint256 startId, // 遍历起始id
                uint256 length // 遍历长度
            ) public view  returns (
                uint256[] memory // 返回id列表
            ) {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 创建 idList
                uint256[] memory idList = new uint256[](length);
                // 初始化 id
                uint48 id = startId;
                // 循环遍历，获取从 startId 的映射，开始的 length 个 id
                for (uint256 i = 0; i < length; i++) {
                    id = _sortMap[id];
                    idList[i] = id;
                }
                // 返回 idList
                return idList;
            }
            ```
        - 总结
            函数 `getIdListBySort` 可以获取从 `_sortMap[startId]` 开始的 `length` 个 `id`，受限于 EVM 机制一次获取的 `length` 最好不超过1万。
- 内部函数（仅合约内部可用）
    - _addSort
        - 代码速览
            ``` javascript
            function _addSort(
                uint256 beforeSortId,
                uint256 id
            ) internal {
                if (beforeSortId == 0) {
                    if (firstSortId != 0) {
                        require(
                            firstSortId <= id,
                            "Sort: sort error"
                        );
                    }
                    _sortMap[id] = firstSortId;
                    firstSortId = id;
                } else if (_sortMap[beforeSortId] == 0) {
                    require(
                        firstSortId >= id,
                        "Sort: sort error"
                    );
                    _sortMap[beforeSortId] = id;
                } else {
                    require(
                        beforeSortId >= id &&
                            _sortMap[beforeSortId] <= id &&
                            beforeSortId !=
                            _sortMap[beforeSortId],
                        "Sort: sort error"
                    );
                    _sortMap[_sortMap[id]] = _sortMap[beforeSortId];
                    _sortMap[beforeSortId] = id;
                }
                sortLength++;
            }
            ```
        - 参数分析
            函数 `_addSort` 的入参有 2 个，出参有 0 个，对应的解释如下：
            ``` javascript
            function _addSort(
                uint256 beforeSortId, // 映射到 id 的 id
                uint256 id // 需要插入的id
            ) internal {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 如果 beforeSortId 等于 0
                if (beforeSortId == 0) {
                    // 如果 firstSortId 不等于 0
                    if (firstSortId != 0) {
                        // firstSortId 需要小于等于 id
                        require(
                            firstSortId <= id,
                            "Sort: sort error"
                        );
                    }
                    // id 映射到 firstSortId
                    _sortMap[id] = firstSortId;
                    // firstSortId 设置为 id
                    firstSortId = id;
                // 如果 beforeSortId 的映射 等于 0
                } else if (_sortMap[beforeSortId] == 0) {
                    // beforeSortId 需要大于等于 id
                    require(
                        beforeSortId >= id,
                        "Sort: sort error"
                    );
                    // beforeSortId 映射到 id
                    _sortMap[beforeSortId] = id;
                } else {
                    // 需要 beforeSortId 大于等于 id 并且 
                    // beforeSortId 的映射小于等于 id 并且 
                    // beforeSortId 不等于 beforeSortId 的映射
                    require(
                        beforeSortId >= id &&
                            _sortMap[beforeSortId] <= id &&
                            beforeSortId !=
                            _sortMap[beforeSortId],
                        "Sort: sort error"
                    );
                    // id 映射到 beforeSortId 的映射
                    _sortMap[id] = _sortMap[beforeSortId];
                    // beforeSortId 映射到 id
                    _sortMap[beforeSortId] = id;
                }
                // 排序长度加 1
                sortLength++;
            }
            ```
        - 总结
            函数 `_addSort` 可以向排序列表中验证并添加 `id`。
    - _removeSort
        - 代码速览
            ``` javascript
            function _removeSort(
                uint256 beforeSortId,
                uint256 id
            ) internal {
                if (beforeSortId == 0) {
                    require(firstSortId == id, "Sort: sort error");
                    firstSortId = _sortMap[firstSortId];
                } else {
                    require(
                        _sortMap[beforeSortId] == id,
                        "Sort: sort error"
                    );
                    _sortMap[beforeSortId] = _sortMap[id];
                }
                sortLength--;
            }
            ```
        - 参数分析
            函数 `_removeSort` 的入参有 2 个，出参有 0 个，对应的解释如下：
            ``` javascript
            function _removeSort(
                uint256 beforeSortId, // 映射到 id 的 id
                uint256 id // 需要移除的id
            ) internal {
                ...
            }
            ```
        - 实现分析
            ``` javascript
            ...
            {
                // 如果 beforeSortId 等于 0
                if (beforeSortId == 0) {
                    // 需要 firstSortId 等于 id
                    require(firstSortId == id, "Sort: sort error");
                    // firstSortId 设置为 firstSortId 的映射
                    firstSortId = _sortMap[firstSortId];
                } else {
                    // 需要 beforeSortId 的映射 等于 id
                    require(
                        _sortMap[beforeSortId] == id,
                        "Sort: sort error"
                    );
                    // beforeSortId 映射到 id 的映射
                    _sortMap[beforeSortId] = _sortMap[id];
                }
                // 排序长度减 1
                sortLength--;
            }
            ```
        - 总结
            函数 `_removeSort` 可以向排序列表中验证并删除 `id`。
## 总结

使用该排序算法有以下要求：

1. 排序只做单向遍历，如果做双向遍历只能另做一个排序。

2. 应用需要从链上获取排序列表，在链下完成查询计算后再放到链上对排序进行验证。

3. 如果排序列表元素数量太多（高于10万），应考虑后端支持。

4. 排序 id 应该从 1 开始计算。