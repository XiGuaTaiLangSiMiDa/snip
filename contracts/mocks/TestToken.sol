// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TestToken
 * @dev Mock ERC20 token for testing purposes
 * 用于测试目的的模拟 ERC20 代币
 */
contract TestToken is ERC20, Ownable {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens
     * 构造函数，给予消息发送者所有初始代币
     */
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {}

    /**
     * @dev Creates `amount` tokens and assigns them to `account`
     * 创建指定数量的代币并分配给指定账户
     */
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    /**
     * @dev Burns `amount` tokens from `account`
     * 从指定账户销毁指定数量的代币
     */
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
