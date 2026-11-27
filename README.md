# Agent Hall · Agent ID 签到身份馆

Agent Hall 是 Agent ID 的链上身份馆，币安 Agentic 钱包黑客松项目。用 Agent ID 做门禁：持有者领取一枚编号声誉徽章，再每天签到一次——徽章、连续天数、等级全部上链，攒成一份绑在地址上、任何人都能公开查验的声誉履历。

- 只有持有 Agent ID 才能参与：合约进站即查官方 Agent ID 注册合约 `balanceOf`，未持有者不能签到 / 领徽章
- 持有者首次领取一枚 ERC-721 声誉徽章，不可转让，编号按领取顺序发放
- 每日签到一次（UTC 自然日），连续签到累计天数，断签重新累计；等级随连续天数提升（Lv1 1 天 / Lv2 7 天 / Lv3 30 天 / Lv4 90 天 / Lv5 180 天）
- 领取与签到不收费，只付链上 Gas（实测每笔 < $0.01）

## 合约

- `contracts/AgentHall.sol` — 主合约：`claimBadge()` / `checkIn()` / 只读 `streakOf` / `levelOf` / `badgeOf` / `hasCheckedInToday`，事件 `CheckIn(address, streak, level)`
- `contracts/interfaces/IAgentIdRegistry.sol` — 官方注册合约最小接口（只用 `balanceOf`）
- `contracts/mocks/MockAgentIdRegistry.sol` — 仅测试用，绝不部署到主网
- 官方 Agent ID 注册合约（BNB Chain）：`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`

## 部署

- 网络：BNB Chain 主网
- 合约地址：`0x9a1a1e97aa3a2f82df425d172ab443d824b9378c`
- 部署时间：2026-11-27
- 源码验证：Sourcify 完全匹配（exact match）；BscScan 合约页显示源码已验证

## 使用方式

入口页（含合约地址与 calldata 一键复制、徽章查询）：https://muse.ai/s/agent-hall-ru-kou-gxd6xfgxjxwxnxjxxk/LmWuiQ-Z_mfILZnnwqLJCl9PO-NvSaMHLcEvefBDUv0

1. 在币安 App 的 Agentic 钱包中开启开发者模式
2. 用「合约调用」打开本合约：领徽章填 `claimBadge()` 的 calldata `0x56e56942`，每日签到填 `checkIn()` 的 calldata `0x183ff085`
3. 每笔操作在 App 内单独确认，只付 Gas

## 本地开发

```bash
npm install
npm run compile
npm test
npm run deploy:testnet   # 需设置 DEPLOYER_KEY 环境变量
```

## 权限与安全披露

- 合约不做资产转移、不做无限授权、不承诺收益
- owner 唯一权限：`setBaseTokenURI`（只改徽章元数据展示，不影响签到 / 等级逻辑）
- Agentic Wallet 调用自定义合约需用户在币安 App 开开发者模式、每次操作单独确认，入口页带有这步引导

## 参考

币安 Agentic 钱包黑客松官方公告：https://www.binance.com/zh-CN/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf
