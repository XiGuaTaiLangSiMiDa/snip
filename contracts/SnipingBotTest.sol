// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SnipingBot.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SnipingBotTest
 * @dev Test contract for SnipingBot
 * 用于测试 SnipingBot 的测试合约
 */
contract SnipingBotTest {
    // Main contract instance | 主合约实例
    SnipingBot public snipingBot;
    
    // Test tokens | 测试代币
    address public testTokenA;
    address public testTokenB;
    
    // Events for testing | 测试事件
    event TestStarted(string testName);
    event TestCompleted(string testName, bool success);
    
    /**
     * @dev Constructor to deploy test environment
     * 构造函数，部署测试环境
     * @param _uniswapRouter Uniswap V2 Router address | Uniswap V2 路由器地址
     * @param _uniswapFactory Uniswap V2 Factory address | Uniswap V2 工厂地址
     */
    constructor(address _uniswapRouter, address _uniswapFactory) {
        // Deploy main contract | 部署主合约
        snipingBot = new SnipingBot(
            _uniswapRouter,
            _uniswapFactory
        );
        
        // Transfer ownership to test contract | 将所有权转移给测试合约
        Ownable(address(snipingBot)).transferOwnership(msg.sender);
    }
    
    /**
     * @dev Test Case 1: Setup whitelist
     * 测试用例1：设置白名单
     * @param tokenA First test token | 第一个测试代币
     * @param tokenB Second test token | 第二个测试代币
     */
    function testWhitelisting(address tokenA, address tokenB) public {
        emit TestStarted("Whitelisting Test");
        
        // Add tokens to whitelist | 将代币添加到白名单
        snipingBot.whitelistToken(tokenA, true);
        snipingBot.whitelistToken(tokenB, true);
        
        // Verify whitelisting | 验证白名单
        require(snipingBot.whitelistedTokens(tokenA), "TokenA not whitelisted");
        require(snipingBot.whitelistedTokens(tokenB), "TokenB not whitelisted");
        
        testTokenA = tokenA;
        testTokenB = tokenB;
        
        emit TestCompleted("Whitelisting Test", true);
    }
    
    /**
     * @dev Test Case 2: Check arbitrage calculation
     * 测试用例2：检查套利计算
     * @param amountIn Amount of input tokens | 输入代币数量
     */
    function testArbitrageCalculation(uint256 amountIn) public {
        emit TestStarted("Arbitrage Calculation Test");
        
        // Calculate potential profit | 计算潜在利润
        uint256 profit = snipingBot.checkPriceArbitrage(testTokenA, testTokenB, amountIn);
        require(profit > 0, "No profit calculated");
        
        // Log results | 记录结果
        emit TestCompleted("Arbitrage Calculation Test", true);
    }
    
    /**
     * @dev Test Case 3: Execute snipe with minimum amount
     * 测试用例3：使用最小金额执行套利
     * @param amountIn Amount of input tokens | 输入代币数量
     */
    function testMinimumSnipe(uint256 amountIn) public {
        emit TestStarted("Minimum Snipe Test");
        
        // Approve tokens | 授权代币
        IERC20(testTokenA).approve(address(snipingBot), amountIn);
        
        // Execute snipe | 执行套利
        try snipingBot.executeSnipe(testTokenA, testTokenB, amountIn) {
            emit TestCompleted("Minimum Snipe Test", true);
        } catch Error(string memory reason) {
            // Log failure reason | 记录失败原因
            emit TestCompleted("Minimum Snipe Test", false);
        }
    }
    
    /**
     * @dev Test Case 4: Test withdrawal functions
     * 测试用例4：测试提现功能
     */
    function testWithdrawals() public {
        emit TestStarted("Withdrawals Test");
        
        // Test ETH withdrawal | 测试 ETH 提现
        try snipingBot.withdrawETH() {
            emit TestCompleted("ETH Withdrawal Test", true);
        } catch {
            emit TestCompleted("ETH Withdrawal Test", false);
        }
        
        // Test token withdrawal | 测试代币提现
        try snipingBot.withdrawToken(testTokenA, 1000) {
            emit TestCompleted("Token Withdrawal Test", true);
        } catch {
            emit TestCompleted("Token Withdrawal Test", false);
        }
    }
}
