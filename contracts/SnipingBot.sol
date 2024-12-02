// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SnipingBot
 * @dev Automated trading bot for sniping arbitrage opportunities on Uniswap
 * 用于在 Uniswap 上寻找套利机会的自动交易机器人
 * 
 * REMIX DEPLOYMENT INSTRUCTIONS | REMIX 部署说明:
 * 1. Open in Remix IDE (https://remix.ethereum.org)
 *    在 Remix IDE 中打开 (https://remix.ethereum.org)
 * 
 * 2. Compile with Solidity 0.8.0 or higher
 *    使用 Solidity 0.8.0 或更高版本编译
 * 
 * 3. Deploy with these parameters | 使用以下参数部署:
 *    - initialOwner: Your wallet address | 您的钱包地址
 *    - Uniswap V2 Router (Ethereum Mainnet): 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
 *    - Uniswap V2 Factory (Ethereum Mainnet): 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
 * 
 * 4. After deployment | 部署后:
 *    - Whitelist tokens using whitelistToken()
 *    - Fund contract with ETH for gas
 *    - Approve tokens for trading
 *    使用 whitelistToken() 将代币加入白名单
 *    为 gas 费用注入 ETH
 *    批准代币进行交易
 */

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getAmountsOut(uint amountIn, address[] calldata path) 
        external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract SnipingBot {
    // Constants | 常量
    uint256 private constant DEADLINE_EXTENSION = 300; // 5 minutes | 5分钟
    uint256 private constant MIN_PROFIT_THRESHOLD = 0.01 ether; // Minimum profit | 最小利润
    uint256 private constant AUTO_CHECK_INTERVAL = 1; // Check every block | 每个区块检查一次
    
    // State variables | 状态变量
    IUniswapV2Router02 public immutable uniswapRouter;
    IUniswapV2Factory public immutable uniswapFactory;
    mapping(address => bool) public whitelistedTokens;
    address public owner;
    bool private locked;
    bool public autoExecuteEnabled;
    uint256 public lastCheckBlock;
    uint256 public maxAmountPerTrade; // Maximum amount per trade | 每笔交易的最大金额
    
    // Trading pairs for auto execution | 自动执行的交易对
    struct TradingPair {
        address tokenA;
        address tokenB;
        uint256 amountIn;
        bool active;
    }
    
    TradingPair[] public tradingPairs;
    
    // Events | 事件
    event ProfitableOpportunity(
        address indexed token0,
        address indexed token1,
        uint256 profit,
        uint256 timestamp
    );
    
    event TradeExecuted(
        address indexed token0,
        address indexed token1,
        uint256 amountIn,
        uint256 amountOut,
        uint256 timestamp
    );

    event AutoExecuteStatusChanged(bool enabled);
    event TradingPairAdded(address tokenA, address tokenB, uint256 amountIn);
    event TradingPairRemoved(address tokenA, address tokenB);

    // Modifiers | 修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(
        address initialOwner,
        address _uniswapRouter,
        address _uniswapFactory
    ) {
        require(initialOwner != address(0), "Owner cannot be zero address");
        require(_uniswapRouter != address(0), "Invalid router address");
        require(_uniswapFactory != address(0), "Invalid factory address");
        
        owner = initialOwner;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        uniswapFactory = IUniswapV2Factory(_uniswapFactory);
        locked = false;
        autoExecuteEnabled = false;
        lastCheckBlock = block.number;
        maxAmountPerTrade = 1 ether; // Default 1 ETH | 默认1 ETH
    }

    /**
     * @dev Add trading pair for auto execution
     * 添加自动执行的交易对
     */
    function addTradingPair(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) external onlyOwner {
        require(whitelistedTokens[tokenA] && whitelistedTokens[tokenB], "Tokens not whitelisted");
        require(amountIn <= maxAmountPerTrade, "Amount exceeds maximum");
        
        tradingPairs.push(TradingPair({
            tokenA: tokenA,
            tokenB: tokenB,
            amountIn: amountIn,
            active: true
        }));
        
        emit TradingPairAdded(tokenA, tokenB, amountIn);
    }

    /**
     * @dev Remove trading pair
     * 移除交易对
     */
    function removeTradingPair(uint256 index) external onlyOwner {
        require(index < tradingPairs.length, "Invalid index");
        emit TradingPairRemoved(tradingPairs[index].tokenA, tradingPairs[index].tokenB);
        tradingPairs[index].active = false;
    }

    /**
     * @dev Set maximum amount per trade
     * 设置每笔交易的最大金额
     */
    function setMaxAmountPerTrade(uint256 amount) external onlyOwner {
        maxAmountPerTrade = amount;
    }

    /**
     * @dev Enable/disable auto execution
     * 启用/禁用自动执行
     */
    function setAutoExecute(bool enabled) external onlyOwner {
        autoExecuteEnabled = enabled;
        emit AutoExecuteStatusChanged(enabled);
    }

    /**
     * @dev Check and execute profitable trades
     * 检查并执行有利可图的交易
     */
    function checkAndExecute() external {
        require(autoExecuteEnabled, "Auto execute not enabled");
        require(block.number >= lastCheckBlock + AUTO_CHECK_INTERVAL, "Check too frequent");
        
        lastCheckBlock = block.number;
        
        for (uint i = 0; i < tradingPairs.length; i++) {
            if (!tradingPairs[i].active) continue;
            
            TradingPair memory pair = tradingPairs[i];
            uint256 profit = checkPriceArbitrage(pair.tokenA, pair.tokenB, pair.amountIn);
            
            if (profit >= MIN_PROFIT_THRESHOLD) {
                _executeSnipe(pair.tokenA, pair.tokenB, pair.amountIn);
            }
        }
    }

    /**
     * @dev Internal function to execute trades
     * 内部执行交易的函数
     */
    function _executeSnipe(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) internal nonReentrant {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenA).approve(address(uniswapRouter), amountIn);
        
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        
        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + DEADLINE_EXTENSION
        );
        
        emit TradeExecuted(
            tokenA,
            tokenB,
            amountIn,
            amounts[1],
            block.timestamp
        );
    }

    /**
     * @dev Check price difference between exchanges
     * 检查交易所之间的价格差异
     */
    function checkPriceArbitrage(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) public view returns (uint256 potentialProfit) {
        require(whitelistedTokens[tokenA] && whitelistedTokens[tokenB], "Tokens not whitelisted");
        
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        
        uint256[] memory amountsOut = uniswapRouter.getAmountsOut(amountIn, path);
        
        if (amountsOut[1] > amountIn) {
            potentialProfit = amountsOut[1] - amountIn;
        }
    }

    /**
     * @dev Manual execute snipe (for testing or specific opportunities)
     * 手动执行套利（用于测试或特定机会）
     */
    function executeSnipe(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) external onlyOwner {
        require(whitelistedTokens[tokenA] && whitelistedTokens[tokenB], "Tokens not whitelisted");
        require(amountIn <= maxAmountPerTrade, "Amount exceeds maximum");
        
        uint256 potentialProfit = checkPriceArbitrage(tokenA, tokenB, amountIn);
        require(potentialProfit >= MIN_PROFIT_THRESHOLD, "Insufficient profit margin");
        
        _executeSnipe(tokenA, tokenB, amountIn);
    }

    function whitelistToken(address token, bool status) external onlyOwner {
        require(token != address(0), "Invalid token address");
        whitelistedTokens[token] = status;
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transfer(owner, amount);
    }

    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = owner.call{value: balance}("");
        require(success, "ETH transfer failed");
    }

    receive() external payable {}
    fallback() external payable {}
}
