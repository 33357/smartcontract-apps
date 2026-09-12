传播区块链技术，躺赢未来人生。
Hello，大家好，我是33357，今天给大家讲合约重入攻击。

首先来讲一下它的原理。
合约重入攻击，是指在同一交易中对业务合约进行多次调用，从而实现对业务合约的攻击。
这要分为两个方面进行解释。
首先是合约重入。
如果业务合约的公开方法中，有提现 Ether 或者调用第三方合约的操作，那么第三方合约就可以对该业务合约的公开方法的进行二次以及多次调用，从而实现合约重入。
而重入攻击，在大多数情况下，利用了业务合约先提现 Ether 或者调用第三方合约，然后再修改合约状态的漏洞，从而对业务合约实现重入攻击。

接下来是流程图。
合约重入的流程是这样的。
首先调用者调用业务合约，业务合约通过提现 Ether 或者调用第三方合约来触发目标合约。目标合约可以再次调用业务合约，形成循环，从而实现合约重入。
然后是重入攻击的流程。
首先调用业务合约的公开方法，完成第一次状态检查。接着通过提现 Ether 或者调用第三方合约来触发目标合约，目标合约会再次调用业务合约。由于此时合约状态没有修改，因此能够通过第二次状态检查。以此类推，直到结束重入，业务合约才会修改合约状态，结束方法。

为了帮助大家更好地理解合约重入攻击，我给大家写了一个简单的示例。
这是一个简单的 Bank 合约示例，它的功能是存入和提现 Ether。如果你看不出合约的问题，说明你正需要学习这节课。提示一下，这个合约有巨大漏洞，仅供教学，请不要直接使用在任何实际业务中。

我会给大家演示如何使用这个示例来完成合约重入攻击。

...

首先来看 Bank 合约的几个方法。
第一个是变量 balance，用来记录用户在 Bank 合约存入的 Ether 余额；第二个是变量 totalDeposit，用来记录所有用户在 Bank 合约存入的 Ether 总额；第三个是方法 ethBalance，用来返回 Bank 合约的真实 Ether 余额；第四个是方法 deposit，用来让用户存入 Ether；第五个是方法 withdraw，用来让用户提现 Ether。

接下来看 ReentrancyAttack 合约的几个方法。

第一个是变量 bank，用来记录 Bank 合约地址；第二个是构造方法 constructor，在合约创建时给变量 bank 赋值；第三个是方法 doDeposit，用来向 Bank 合约存入 Ether；第四个是方法 doWithdraw，用来从 Bank 合约提现 Ether；第五个是方法 receive，当 Bank 合约向 ReentrancyAttack 合约转账 Ether 时触发，调用 Bank 合约再次提现。

当用户调用 ReentrancyAttack 合约的 doWithdraw 方法时，会触发 Bank 合约的 withdraw 方法，withdraw 方法会检查 ReentrancyAttack 合约的 balance 是否大于 0，然后向 ReentrancyAttack 合约转账 Ether。而这会触发 ReentrancyAttack 合约的 receive 方法，再次调用 Bank 合约的 withdraw 方法。由于没有改变 balance 的状态， ReentrancyAttack 的 balance 任然大于 0，因此 Bank 合约会再次向 ReentrancyAttack 合约转账 Ether，再次触发 ReentrancyAttack 合约的 receive 方法。这个步骤会循环执行，直到 Bank 合约的 Ether 余额为 0，转账失败，才能跳出循环。

最后执行结果，totalDeposit 会减去 ReentrancyAttack 合约的 balance 余额，ReentrancyAttack 合约的 balance 为 0。但实际上 ReentrancyAttack 合约获取了 Bank 合约的所有 Ether 余额。

最后，我们来看一下如何防止合约重入攻击。

第一个方法就是禁止合约重入。
使用修饰函数 nonReentrant 可以有效防止合约重入，自然也就不会有合约重入攻击了。这里推荐使用openzeppelin 的官方防重入合约。

第二个方法是在提现 Ether 或者调用第三方合约之前，先修改合约状态。
这样可以防止第三方合约利用重入操作攻击业务合约。

第三个方法是禁止转账 Ether 到合约地址。
如果业务合约只有转账 Ether 到合约地址这一个可能调用第三方合约的方法，那么也可以有效防止重入攻击。

OK，今天合约重入攻击的课就讲完了，本期课程文稿放在 github 上，搜索smartcontract-apps，点击 “100 个 Solidity 使用技巧” 就可以看到了，欢迎大家继续支持我的课程。