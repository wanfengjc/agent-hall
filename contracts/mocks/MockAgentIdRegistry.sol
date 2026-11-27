// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice 仅测试用：模拟 Agent ID 注册合约的 balanceOf，供 Hardhat 测试调用。
/// @dev 绝不部署到主网；主网只认官方注册合约 0x60b9262456de011f7d15a54cdd8c48baaa8b022f。
contract MockAgentIdRegistry {
    mapping(address => uint256) private _balances;

    function setBalance(address account, uint256 amount) external {
        _balances[account] = amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
}
