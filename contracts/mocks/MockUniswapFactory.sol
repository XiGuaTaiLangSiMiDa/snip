// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockUniswapFactory
 * @dev Mock contract for testing Uniswap Factory functionality
 * 用于测试 Uniswap 工厂功能的模拟合约
 */
contract MockUniswapFactory {
    mapping(address => mapping(address => address)) public pairs;

    /**
     * @dev Get the pair address for two tokens
     * 获取两个代币的交易对地址
     */
    function getPair(address tokenA, address tokenB) external view returns (address) {
        return pairs[tokenA][tokenB];
    }

    /**
     * @dev Mock function to set pairs for testing
     * 用于测试的模拟设置交易对函数
     */
    function setPair(address tokenA, address tokenB, address pair) external {
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
    }
}
