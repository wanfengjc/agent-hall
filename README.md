# Agent Hall · Agent ID 签到身份馆

币安 Agent ID 黑客松主赛道（轻量版）参赛作品：用 Agent ID 做门禁的每日签到 + 声誉徽章。

- 只有持有 Agent ID 才能进：进站即查官方 Agent ID 注册合约 `balanceOf`，未持有者只看介绍、不能签到/领徽章
- 持有者首次领取一枚 ERC-721 声誉徽章，不可转让，徽章上记录签到天数与等级
- 每日签到一次（UTC 自然日），连续签到累计天数，断签重新累计；等级随连续天数提升（Lv1 1 天 / Lv2 7 天 / Lv3 30 天 / Lv4 90 天 / Lv5 180 天）

## 合约

- `contracts/AgentHall.sol` — 主合约：`claimBadge()` / `checkIn()` / 只读 `streakOf` / `levelOf` / `badgeOf` / `hasCheckedInToday`，事件 `CheckIn(address, streak, level)`
- `contracts/interfaces/IAgentIdRegistry.sol` — 官方注册合约最小接口（只用 `balanceOf`）
- `contracts/mocks/MockAgentIdRegistry.sol` — 仅测试用，绝不部署到主网
- 官方 Agent ID 注册合约（BNB Chain）：`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`

## 本地开发

```bash
npm install
npm run compile
npm test
npm run deploy:testnet   # 需设置 DEPLOYER_KEY 环境变量
```

## 部署

- 11-25 测试网联调；11-27 主网部署（部署前先报 gas，由 Wan 本人签名）
- 部署后做 BscScan 源码验证，仓库保持开源

## 权限与安全披露

- 合约不做资产转移、不做无限授权、不承诺收益
- owner 唯一权限：`setBaseTokenURI`（只改徽章元数据展示，不影响签到/等级逻辑）
- Agentic Wallet 调用自定义合约需用户在币安 App 开开发者模式、每次操作单独确认，页面与推广文案会带这步引导

## 时间线

11-20 开工 → 11-21 合约骨架 → 11-22~24 合约+前端 → 11-25 测试网联调 → 11-26 开源整理+BscScan 验证准备 → 11-27 主网部署 → 11-28~12-08 推广凑交互 → 12-07 提前提交 → 硬截止 12-09 16:00（北京时间）

目标口径：完成一份合格提交，不冲奖；不买量、不刷假交互。

官方公告：https://www.binance.com/zh-CN/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf
