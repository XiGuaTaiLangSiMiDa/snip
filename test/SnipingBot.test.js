const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SnipingBot Tests | 套利机器人测试", function () {
    let SnipingBot;
    let SnipingBotTest;
    let TestToken;
    let snipingBot;
    let snipingBotTest;
    let tokenA;
    let tokenB;
    let owner;
    let addr1;
    let addr2;
    let uniswapRouter;
    let uniswapFactory;

    // Deploy mock tokens for testing
    // 部署测试用的模拟代币
    async function deployTestToken(name, symbol) {
        const Token = await ethers.getContractFactory("TestToken");
        const token = await Token.deploy(name, symbol);
        await token.deployed();
        return token;
    }

    beforeEach(async function () {
        // Get signers for testing
        // 获取测试用的签名者
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy mock Uniswap contracts
        // 部署模拟的 Uniswap 合约
        const MockUniswapFactory = await ethers.getContractFactory("MockUniswapFactory");
        uniswapFactory = await MockUniswapFactory.deploy();
        await uniswapFactory.deployed();

        const MockUniswapRouter = await ethers.getContractFactory("MockUniswapRouter");
        uniswapRouter = await MockUniswapRouter.deploy(uniswapFactory.address);
        await uniswapRouter.deployed();

        // Deploy test tokens
        // 部署测试代币
        tokenA = await deployTestToken("Test Token A", "TSTA");
        tokenB = await deployTestToken("Test Token B", "TSTB");

        // Deploy test contract
        // 部署测试合约
        const SnipingBotTest = await ethers.getContractFactory("SnipingBotTest");
        snipingBotTest = await SnipingBotTest.deploy(uniswapRouter.address, uniswapFactory.address);
        await snipingBotTest.deployed();

        // Get reference to main contract
        // 获取主合约引用
        snipingBot = await ethers.getContractAt("SnipingBot", await snipingBotTest.snipingBot());

        // Fund test tokens
        // 为测试代币注资
        const initialAmount = ethers.utils.parseEther("10000");
        
        // Mint tokens to owner
        await tokenA.mint(owner.address, initialAmount);
        await tokenB.mint(owner.address, initialAmount);
        
        // Mint tokens to contracts
        await tokenA.mint(snipingBot.address, initialAmount);
        await tokenB.mint(snipingBot.address, initialAmount);
        await tokenA.mint(uniswapRouter.address, initialAmount);
        await tokenB.mint(uniswapRouter.address, initialAmount);
    });

    describe("Whitelisting Tests | 白名单测试", function () {
        it("Should whitelist tokens successfully | 应该成功将代币加入白名单", async function () {
            await snipingBot.whitelistToken(tokenA.address, true);
            await snipingBot.whitelistToken(tokenB.address, true);
            
            expect(await snipingBot.whitelistedTokens(tokenA.address)).to.be.true;
            expect(await snipingBot.whitelistedTokens(tokenB.address)).to.be.true;
        });

        it("Should fail with zero address | 零地址应该失败", async function () {
            await expect(
                snipingBot.whitelistToken(ethers.constants.AddressZero, true)
            ).to.be.revertedWith("Invalid token address");
        });
    });

    describe("Arbitrage Tests | 套利测试", function () {
        beforeEach(async function () {
            await snipingBot.whitelistToken(tokenA.address, true);
            await snipingBot.whitelistToken(tokenB.address, true);
        });

        it("Should calculate arbitrage profit | 应该计算套利利润", async function () {
            const amountIn = ethers.utils.parseEther("1");
            const profit = await snipingBot.checkPriceArbitrage(tokenA.address, tokenB.address, amountIn);
            expect(profit).to.be.gt(0);
        });

        it("Should execute profitable trade | 应该执行有利可图的交易", async function () {
            const amountIn = ethers.utils.parseEther("1");
            await tokenA.approve(snipingBot.address, amountIn);
            
            await expect(
                snipingBot.executeSnipe(tokenA.address, tokenB.address, amountIn)
            ).to.emit(snipingBot, "TradeExecuted");
        });

        it("Should fail with insufficient profit | 利润不足应该失败", async function () {
            const tinyAmount = ethers.utils.parseEther("0.0001");
            await tokenA.approve(snipingBot.address, tinyAmount);
            
            await expect(
                snipingBot.executeSnipe(tokenA.address, tokenB.address, tinyAmount)
            ).to.be.revertedWith("Insufficient profit margin");
        });
    });

    describe("Withdrawal Tests | 提现测试", function () {
        beforeEach(async function () {
            // Fund contract with ETH
            // 为合约注入 ETH
            await owner.sendTransaction({
                to: snipingBot.address,
                value: ethers.utils.parseEther("1")
            });
        });

        it("Should withdraw ETH successfully | 应该成功提取 ETH", async function () {
            const initialBalance = await ethers.provider.getBalance(owner.address);
            const contractBalance = await ethers.provider.getBalance(snipingBot.address);
            
            const tx = await snipingBot.withdrawETH();
            await tx.wait();

            const finalBalance = await ethers.provider.getBalance(owner.address);
            expect(await ethers.provider.getBalance(snipingBot.address)).to.equal(0);
            // Account for gas costs in the comparison
            expect(finalBalance.sub(initialBalance)).to.be.lt(contractBalance);
        });

        it("Should withdraw tokens successfully | 应该成功提取代币", async function () {
            const amount = ethers.utils.parseEther("1");
            const initialBalance = await tokenA.balanceOf(owner.address);
            
            await snipingBot.withdrawToken(tokenA.address, amount);
            
            const finalBalance = await tokenA.balanceOf(owner.address);
            expect(finalBalance.sub(initialBalance)).to.equal(amount);
        });
    });

    describe("Gas Usage Tests | Gas 使用测试", function () {
        it("Should track gas usage | 应该追踪 gas 使用情况", async function () {
            const amountIn = ethers.utils.parseEther("1");
            await snipingBot.whitelistToken(tokenA.address, true);
            await snipingBot.whitelistToken(tokenB.address, true);
            await tokenA.approve(snipingBot.address, amountIn);
            
            const tx = await snipingBot.executeSnipe(tokenA.address, tokenB.address, amountIn);
            const receipt = await tx.wait();
            console.log('Gas Used for Snipe:', receipt.gasUsed.toString());
            expect(receipt.gasUsed.gt(0)).to.be.true;
        });
    });
});
