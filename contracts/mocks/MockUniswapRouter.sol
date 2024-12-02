// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MockUniswapFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MockUniswapRouter
 * @dev Mock contract for testing Uniswap Router functionality
 * 用于测试 Uniswap 路由器功能的模拟合约
 */
contract MockUniswapRouter {
    MockUniswapFactory public factory;
    
    // Mock exchange rate for testing (1.1:1 to ensure profit)
    // 用于测试的模拟兑换率 (1.1:1 确保有利润)
    uint256 public constant MOCK_RATE = 110; // 110% return for testing
    uint256 public constant RATE_DENOMINATOR = 100;

    constructor(address _factory) {
        factory = MockUniswapFactory(_factory);
    }

    /**
     * @dev Mock function to simulate token swaps
     * 模拟代币交换的函数
     */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        require(path.length >= 2, "UniswapV2Router: INVALID_PATH");
        
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        
        // Mock the swap by transferring tokens
        // 通过转移代币来模拟交换
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        // Calculate mock output amount (110% return for testing)
        // 计算模拟输出金额（测试用110%返回）
        amounts[path.length - 1] = (amountIn * MOCK_RATE) / RATE_DENOMINATOR;
        
        // Transfer output tokens
        // 转移输出代币
        IERC20(path[path.length - 1]).transfer(to, amounts[path.length - 1]);
        
        return amounts;
    }

    /**
     * @dev Mock function to get amounts out
     * 获取输出金额的模拟函数
     */
    function getAmountsOut(uint amountIn, address[] calldata path) 
        external 
        pure 
        returns (uint[] memory amounts) 
    {
        require(path.length >= 2, "UniswapV2Router: INVALID_PATH");
        
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        
        // Mock calculation (110% return for testing)
        // 模拟计算（测试用110%返回）
        for(uint i = 1; i < path.length; i++) {
            amounts[i] = (amounts[i-1] * MOCK_RATE) / RATE_DENOMINATOR;
        }
        
        return amounts;
    }
}
