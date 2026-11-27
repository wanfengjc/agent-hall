// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IAgentIdRegistry.sol";

/// @title AgentHall — Agent ID 签到身份馆
/// @notice 币安 Agent ID 黑客松主赛道（轻量版）：用 Agent ID 做门禁的每日签到 + 声誉徽章。
/// @dev 门禁：调用官方 Agent ID 注册合约 balanceOf，>0 即持有。
///      徽章：ERC-721 灵魂绑定（不可转让），每地址 1 枚，记录连续签到天数与等级。
///      安全：不做资产转移、不做无限授权、不承诺收益；owner 唯一权限是设置
///      baseTokenURI（仅影响徽章元数据展示），权限见 README 披露。
contract AgentHall {
    IAgentIdRegistry public immutable agentIdRegistry;

    string public constant name = "Agent Hall Reputation Badge";
    string public constant symbol = "AHBADGE";

    uint256 public constant DAY = 1 days;
    uint256 public nextTokenId = 1;

    // 等级门槛（按连续签到天数）：Lv1 1 天，Lv2 7 天，Lv3 30 天，Lv4 90 天，Lv5 180 天
    uint256 public constant LEVEL_2_STREAK = 7;
    uint256 public constant LEVEL_3_STREAK = 30;
    uint256 public constant LEVEL_4_STREAK = 90;
    uint256 public constant LEVEL_5_STREAK = 180;

    // tokenId 0 = 未领徽章；tokenId 从 1 开始顺序发放
    mapping(address => uint256) public badgeOf;
    mapping(address => uint256) public streakOf;
    mapping(address => uint256) public lastCheckInDay; // UTC 天数编号 = block.timestamp / 1 days

    mapping(uint256 => address) private _badgeOwner;
    mapping(address => uint256) private _badgeBalance;

    address public owner;
    string public baseTokenURI;

    event BadgeClaimed(address indexed user, uint256 indexed tokenId);
    event CheckIn(address indexed user, uint256 streak, uint256 level);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    error NotAgentIdHolder();
    error BadgeAlreadyClaimed();
    error NoBadge();
    error TokenDoesNotExist();
    error AlreadyCheckedInToday();
    error Soulbound();
    error NotOwner();

    modifier onlyAgentIdHolder() {
        if (agentIdRegistry.balanceOf(msg.sender) == 0) revert NotAgentIdHolder();
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address registry) {
        agentIdRegistry = IAgentIdRegistry(registry);
        owner = msg.sender;
    }

    /// @notice 持有 Agent ID 者首次领取声誉徽章（每地址 1 枚，不可转让）
    function claimBadge() external onlyAgentIdHolder {
        if (badgeOf[msg.sender] != 0) revert BadgeAlreadyClaimed();
        uint256 tokenId = nextTokenId++;
        badgeOf[msg.sender] = tokenId;
        _badgeOwner[tokenId] = msg.sender;
        _badgeBalance[msg.sender] = 1;
        emit Transfer(address(0), msg.sender, tokenId);
        emit BadgeClaimed(msg.sender, tokenId);
    }

    /// @notice 每日签到一次（UTC 自然日）。连续签到累计天数，断签重新累计。
    function checkIn() external onlyAgentIdHolder {
        if (badgeOf[msg.sender] == 0) revert NoBadge();
        uint256 today = block.timestamp / DAY;
        uint256 last = lastCheckInDay[msg.sender];
        if (last == today) revert AlreadyCheckedInToday();
        uint256 streak = (last == today - 1) ? streakOf[msg.sender] + 1 : 1;
        streakOf[msg.sender] = streak;
        lastCheckInDay[msg.sender] = today;
        emit CheckIn(msg.sender, streak, levelOf(msg.sender));
    }

    /// @notice 按连续签到天数算等级：0 = 未领徽章/未签到，1–5 级
    function levelOf(address user) public view returns (uint256) {
        uint256 streak = streakOf[user];
        if (streak >= LEVEL_5_STREAK) return 5;
        if (streak >= LEVEL_4_STREAK) return 4;
        if (streak >= LEVEL_3_STREAK) return 3;
        if (streak >= LEVEL_2_STREAK) return 2;
        if (streak >= 1) return 1;
        return 0;
    }

    function hasCheckedInToday(address user) public view returns (bool) {
        return lastCheckInDay[user] == block.timestamp / DAY;
    }

    // ---- 最小 ERC-721 读接口（徽章展示用；全部转移/授权均 revert，即灵魂绑定） ----

    function balanceOf(address account) public view returns (uint256) {
        return _badgeBalance[account];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address account = _badgeOwner[tokenId];
        if (account == address(0)) revert TokenDoesNotExist();
        return account;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        if (_badgeOwner[tokenId] == address(0)) revert TokenDoesNotExist();
        return string.concat(baseTokenURI, _toString(tokenId));
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165
            || interfaceId == 0x80ac58cd // ERC721
            || interfaceId == 0x5b5e139f; // ERC721Metadata
    }

    function approve(address, uint256) public pure {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public pure {
        revert Soulbound();
    }

    function transferFrom(address, address, uint256) public pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256) public pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) public pure {
        revert Soulbound();
    }

    /// @notice 仅 owner 可设徽章元数据 base URI（只影响展示，不影响签到/等级逻辑）
    function setBaseTokenURI(string calldata uri) external onlyOwner {
        baseTokenURI = uri;
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
