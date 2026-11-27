// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice 官方 Agent ID 注册合约（BNB Chain，SPACE ID Agent ID，ERC-721 不可转让）
/// @dev 本项目只用到 balanceOf：>0 即持有 Agent ID。地址：
///      0x60b9262456de011f7d15a54cdd8c48baaa8b022f
interface IAgentIdRegistry {
    function balanceOf(address account) external view returns (uint256);
}
