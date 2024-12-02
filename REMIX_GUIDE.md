# Remix Deployment Guide
# Remix 部署指南

## Setup | 设置

1. Open Remix IDE: https://remix.ethereum.org
   打开 Remix IDE: https://remix.ethereum.org

2. Create new file: SnipingBot.sol
   创建新文件: SnipingBot.sol

3. Copy the entire content of SnipingBot.sol into Remix
   将 SnipingBot.sol 的全部内容复制到 Remix

## Compilation | 编译

1. Select Solidity Compiler (0.8.0 or higher)
   选择 Solidity 编译器 (0.8.0 或更高版本)

2. Enable optimization (recommended)
   启用优化（推荐）
   - Set optimization runs to 200
   - 将优化运行次数设置为 200

3. Click "Compile SnipingBot.sol"
   点击 "编译 SnipingBot.sol"

## Deployment | 部署

1. Switch to "Deploy & Run Transactions"
   切换到 "部署和运行交易"

2. Select Environment:
   选择环境：
   - For testing: "Injected Web3" with a testnet (Goerli, Sepolia)
   - For mainnet: "Injected Web3" with Ethereum Mainnet
   - 测试：使用测试网络的 "Injected Web3"（Goerli、Sepolia）
   - 主网：使用以太坊主网的 "Injected Web3"

3. Deploy with constructor parameters:
   使用构造函数参数部署：
   ```
   Ethereum Mainnet:
   initialOwner: Your wallet address (e.g., MetaMask address)
   _uniswapRouter: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
   _uniswapFactory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
   ```

## Post-Deployment Setup | 部署后设置

1. Whitelist Tokens | 将代币加入白名单
   - Call whitelistToken() for each token you want to trade
   - Parameters: token address (address), status (true)
   - 为每个要交易的代币调用 whitelistToken()
   - 参数：代币地址 (address)，状态 (true)

2. Fund Contract | 注资合约
   - Send ETH to contract for gas fees
   - Approve tokens for trading
   - 向合约发送 ETH 用于 gas 费用
   - 批准代币进行交易

## Usage | 使用

1. Check Opportunities | 检查机会
   - Call checkPriceArbitrage() to verify profit potential
   - Parameters: tokenA, tokenB, amountIn
   - 调用 checkPriceArbitrage() 验证利润潜力
   - 参数：tokenA、tokenB、amountIn

2. Execute Trades | 执行交易
   - Call executeSnipe() when profitable opportunity found
   - Parameters: tokenA, tokenB, amountIn
   - 发现盈利机会时调用 executeSnipe()
   - 参数：tokenA、tokenB、amountIn

3. Withdraw Profits | 提取利润
   - Use withdrawToken() for token withdrawals
   - Use withdrawETH() for ETH withdrawals
   - 使用 withdrawToken() 提取代币
   - 使用 withdrawETH() 提取 ETH

## Security Notes | 安全注意事项

1. Always test on testnet first
   始终先在测试网络上测试

2. Start with small amounts
   从小额开始

3. Monitor gas prices and adjust accordingly
   监控 gas 价格并相应调整

4. Verify token contracts before whitelisting
   在将代币加入白名单之前验证代币合约

5. Keep private keys secure
   确保私钥安全

## Troubleshooting | 故障排除

1. If transaction fails:
   如果交易失败：
   - Check gas price and limits
   - Verify token approvals
   - Ensure sufficient balances
   - 检查 gas 价格和限制
   - 验证代币授权
   - 确保余额充足

2. If profit check returns 0:
   如果利润检查返回 0：
   - Verify token pair exists
   - Check token liquidity
   - 验证代币对是否存在
   - 检查代币流动性

3. If withdrawal fails:
   如果提现失败：
   - Verify you're using owner account
   - Check contract balances
   - 验证您使用的是所有者账户
   - 检查合约余额

## Important Notes | 重要说明

1. The initialOwner parameter should be set to your wallet address
   initialOwner 参数应设置为您的钱包地址

2. Only the owner can:
   只有所有者可以：
   - Execute trades
   - Whitelist tokens
   - Withdraw funds
   - 执行交易
   - 设置白名单
   - 提取资金

3. Make sure you're connected with the correct wallet when deploying
   部署时确保连接了正确的钱包
