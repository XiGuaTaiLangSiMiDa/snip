# SnipingBot Testing Guide
# 套利机器人测试指南

## Prerequisites | 前置要求

1. Ethereum Development Environment | 以太坊开发环境
   - Hardhat or Truffle | Hardhat 或 Truffle
   - Local Ethereum network (e.g., Hardhat Network, Ganache) | 本地以太坊网络（如 Hardhat Network、Ganache）

2. Test Tokens | 测试代币
   - Deploy test ERC20 tokens for testing | 部署测试用的 ERC20 代币
   - Ensure sufficient token balance | 确保有足够的代币余额

3. Uniswap Setup | Uniswap 设置
   - Local Uniswap V2 Router | 本地 Uniswap V2 路由器
   - Local Uniswap V2 Factory | 本地 Uniswap V2 工厂合约

## Test Cases | 测试用例

### 1. Whitelisting Test | 白名单测试
```javascript
// Test adding tokens to whitelist
// 测试添加代币到白名单
await snipingBotTest.testWhitelisting(tokenA.address, tokenB.address);
```

Expected Results | 预期结果:
- Both tokens should be successfully whitelisted | 两个代币都应该成功添加到白名单
- Event 'TestCompleted' should be emitted with success=true | 应该触发 'TestCompleted' 事件，success=true

### 2. Arbitrage Calculation Test | 套利计算测试
```javascript
// Test arbitrage calculation with 1 ETH
// 使用 1 ETH 测试套利计算
const amountIn = ethers.utils.parseEther("1");
await snipingBotTest.testArbitrageCalculation(amountIn);
```

Expected Results | 预期结果:
- Should return potential profit calculation | 应该返回潜在利润计算结果
- Should not revert if tokens are whitelisted | 如果代币在白名单中不应该回滚

### 3. Minimum Snipe Test | 最小套利测试
```javascript
// Test minimum profitable trade
// 测试最小盈利交易
const minAmount = ethers.utils.parseEther("0.1");
await snipingBotTest.testMinimumSnipe(minAmount);
```

Expected Results | 预期结果:
- Should execute if profit threshold is met | 如果达到利润阈值应该执行
- Should revert if profit is below threshold | 如果利润低于阈值应该回滚

### 4. Withdrawal Test | 提现测试
```javascript
// Test withdrawal functions
// 测试提现功能
await snipingBotTest.testWithdrawals();
```

Expected Results | 预期结果:
- Should successfully withdraw ETH if balance exists | 如果有余额应该成功提取 ETH
- Should successfully withdraw tokens if balance exists | 如果有余额应该成功提取代币

## Error Cases | 错误情况

1. Invalid Token Addresses | 无效代币地址
```javascript
// Should revert with "Invalid token address"
// 应该回滚并提示 "Invalid token address"
await snipingBotTest.testWhitelisting(ethers.constants.AddressZero, tokenB.address);
```

2. Non-whitelisted Tokens | 未白名单代币
```javascript
// Should revert with "Tokens not whitelisted"
// 应该回滚并提示 "Tokens not whitelisted"
await snipingBotTest.testArbitrageCalculation(nonWhitelistedToken, amountIn);
```

3. Insufficient Profit | 利润不足
```javascript
// Should revert with "Insufficient profit margin"
// 应该回滚并提示 "Insufficient profit margin"
const tinyAmount = ethers.utils.parseEther("0.0001");
await snipingBotTest.testMinimumSnipe(tinyAmount);
```

## Security Considerations | 安全考虑

1. Reentrancy Protection | 重入保护
   - All external calls are protected against reentrancy | 所有外部调用都有重入保护
   - Test by creating malicious token contracts | 通过创建恶意代币合约进行测试

2. Access Control | 访问控制
   - Only owner can execute critical functions | 只有所有者可以执行关键功能
   - Test with non-owner accounts | 使用非所有者账户测试

3. Input Validation | 输入验证
   - All address inputs are validated | 所有地址输入都经过验证
   - All amount inputs are checked | 所有金额输入都经过检查

## Gas Optimization Tests | Gas 优化测试

1. Monitor gas usage for key functions | 监控关键功能的 gas 使用情况:
```javascript
const tx = await snipingBotTest.testMinimumSnipe(amountIn);
const receipt = await tx.wait();
console.log('Gas Used:', receipt.gasUsed.toString());
```

2. Compare gas usage across different input sizes | 比较不同输入大小的 gas 使用情况

## Deployment Verification | 部署验证

1. Verify contract addresses | 验证合约地址
2. Verify initial state | 验证初始状态
3. Verify owner rights | 验证所有者权限
4. Verify token approvals | 验证代币授权

## Monitoring | 监控

Monitor these events during testing | 测试时监控这些事件:
- ProfitableOpportunity
- TradeExecuted
- TestStarted
- TestCompleted

## Troubleshooting | 故障排除

Common issues and solutions | 常见问题和解决方案:
1. Insufficient gas | gas 不足
   - Increase gas limit | 增加 gas 限制
2. Pending transactions | 待处理交易
   - Clear pending transactions | 清除待处理交易
3. Network congestion | 网络拥堵
   - Adjust gas price | 调整 gas 价格
