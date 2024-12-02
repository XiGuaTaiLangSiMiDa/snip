# SnipingBot 部署和使用指南
# SnipingBot Deployment and Usage Guide

## 目录 | Table of Contents
1. [部署准备 | Deployment Preparation](#1-部署准备--deployment-preparation)
2. [合约部署 | Contract Deployment](#2-合约部署--contract-deployment)
3. [初始配置 | Initial Configuration](#3-初始配置--initial-configuration)
4. [自动交易设置 | Auto-Trading Setup](#4-自动交易设置--auto-trading-setup)
5. [监控和维护 | Monitoring and Maintenance](#5-监控和维护--monitoring-and-maintenance)
6. [安全建议 | Security Recommendations](#6-安全建议--security-recommendations)
7. [故障排除 | Troubleshooting](#7-故障排除--troubleshooting)

## 1. 部署准备 | Deployment Preparation

### 准备工作 | Prerequisites
- MetaMask 钱包已安装 | MetaMask wallet installed
- 足够的 ETH 用于部署和 gas | Sufficient ETH for deployment and gas
- 要交易的代币余额 | Token balances for trading

### 环境准备 | Environment Setup
1. 访问 Remix IDE: https://remix.ethereum.org
2. 创建新文件 SnipingBot.sol
3. 复制合约代码到 Remix
4. 选择 Solidity 编译器版本 0.8.0 或更高

## 2. 合约部署 | Contract Deployment

### 编译合约 | Compile Contract
1. 选择 "Solidity Compiler" 标签
2. 设置编译器版本 >= 0.8.0
3. 启用优化，设置为 200 runs
4. 点击 "Compile SnipingBot.sol"

### 部署步骤 | Deployment Steps
1. 切换到 "Deploy & Run Transactions" 标签
2. 环境选择 "Injected Web3"
3. 确保连接到正确的网络
4. 准备部署参数：
   ```
   initialOwner: 您的钱包地址 | Your wallet address
   _uniswapRouter: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
   _uniswapFactory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
   ```
5. 点击 "Deploy" 并确认交易

## 3. 初始配置 | Initial Configuration

### 设置代币白名单 | Whitelist Tokens
```solidity
// 为每个要交易的代币调用
whitelistToken(tokenAddress, true)
```

### 设置交易限额 | Set Trading Limits
```solidity
// 设置每笔交易的最大金额（默认1 ETH）
setMaxAmountPerTrade(maxAmount)
```

### 注入资金 | Fund Contract
1. 转入 ETH 用于 gas 费用
2. 为要交易的代币授权
   ```solidity
   // 在代币合约中调用
   approve(snipingBotAddress, amount)
   ```

## 4. 自动交易设置 | Auto-Trading Setup

### 添加交易对 | Add Trading Pairs
```solidity
// 为每个要监控的交易对调用
addTradingPair(
    tokenA,  // 第一个代币地址
    tokenB,  // 第二个代币地址
    amountIn // 交易金额
)
```

### 启用自动执行 | Enable Auto-Execution
```solidity
// 启用自动交易
setAutoExecute(true)
```

### 触发检查 | Trigger Checks
可以通过以下方式触发检查：
1. 外部服务定期调用 checkAndExecute()
2. MEV 机器人监控
3. Chainlink Keeper 网络
4. 自定义脚本

## 5. 监控和维护 | Monitoring and Maintenance

### 监控交易 | Monitor Trades
- 监听 TradeExecuted 事件
- 监听 ProfitableOpportunity 事件
- 检查合约余额变化

### 管理交易对 | Manage Trading Pairs
```solidity
// 移除不活跃的交易对
removeTradingPair(index)

// 添加新的交易对
addTradingPair(tokenA, tokenB, amountIn)
```

### 提取利润 | Withdraw Profits
```solidity
// 提取 ETH
withdrawETH()

// 提取代币
withdrawToken(tokenAddress, amount)
```

## 6. 安全建议 | Security Recommendations

### 风险控制 | Risk Management
1. 从小额开始测试
2. 逐步增加交易金额
3. 设置合理的利润阈值
4. 定期检查代币授权

### 安全措施 | Security Measures
1. 使用硬件钱包
2. 定期更新白名单
3. 监控异常交易
4. 保持私钥安全

## 7. 故障排除 | Troubleshooting

### 常见问题 | Common Issues
1. 交易失败
   - 检查 gas 价格和限制
   - 验证代币授权
   - 确认余额充足

2. 自动执行未触发
   - 验证 autoExecuteEnabled 状态
   - 检查区块间隔设置
   - 确认交易对状态

3. 利润检查返回零
   - 验证代币对是否存在
   - 检查代币流动性
   - 确认价格预言机状态

### 紧急操作 | Emergency Actions
1. 暂停自动执行
   ```solidity
   setAutoExecute(false)
   ```

2. 移除所有交易对
   ```solidity
   // 遍历并移除所有交易对
   for (uint i = 0; i < tradingPairs.length; i++) {
       removeTradingPair(i);
   }
   ```

3. 紧急提现
   ```solidity
   // 提取所有 ETH
   withdrawETH()
   
   // 提取所有代币
   withdrawToken(tokenAddress, balance)
   ```

## 代码示例 | Code Examples

### 完整部署和设置流程 | Complete Deployment and Setup Flow
```javascript
// 1. 部署合约
const SnipingBot = await ethers.getContractFactory("SnipingBot");
const bot = await SnipingBot.deploy(
    owner.address,
    UNISWAP_ROUTER,
    UNISWAP_FACTORY
);
await bot.deployed();

// 2. 设置白名单
await bot.whitelistToken(TOKEN_A, true);
await bot.whitelistToken(TOKEN_B, true);

// 3. 设置交易限额
await bot.setMaxAmountPerTrade(ethers.utils.parseEther("1"));

// 4. 添加交易对
await bot.addTradingPair(
    TOKEN_A,
    TOKEN_B,
    ethers.utils.parseEther("0.1")
);

// 5. 启用自动执行
await bot.setAutoExecute(true);

// 6. 设置自动检查
setInterval(async () => {
    await bot.checkAndExecute();
}, 15000); // 每15秒检查一次
```

### 监控事件 | Monitoring Events
```javascript
// 监听交易执行事件
bot.on("TradeExecuted", (token0, token1, amountIn, amountOut, timestamp) => {
    console.log(`
        Trade Executed:
        Token A: ${token0}
        Token B: ${token1}
        Amount In: ${ethers.utils.formatEther(amountIn)}
        Amount Out: ${ethers.utils.formatEther(amountOut)}
        Time: ${new Date(timestamp * 1000)}
    `);
});

// 监听利润机会事件
bot.on("ProfitableOpportunity", (token0, token1, profit, timestamp) => {
    console.log(`
        Profit Opportunity Found:
        Token A: ${token0}
        Token B: ${token1}
        Potential Profit: ${ethers.utils.formatEther(profit)}
        Time: ${new Date(timestamp * 1000)}
    `);
});
```

记住：
- 始终在测试网络上先测试
- 从小额开始逐步增加
- 定期监控和维护
- 保持安全意识
