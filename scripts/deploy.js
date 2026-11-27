const hre = require("hardhat");

// 官方 Agent ID 注册合约（BNB Chain，SPACE ID Agent ID，ERC-721 不可转让）
const AGENT_ID_REGISTRY = "0x60b9262456de011f7d15a54cdd8c48baaa8b022f";

async function main() {
  const registry = process.env.AGENT_ID_REGISTRY || AGENT_ID_REGISTRY;
  const AgentHall = await hre.ethers.getContractFactory("AgentHall");
  const hall = await AgentHall.deploy(registry);
  await hall.waitForDeployment();
  const address = await hall.getAddress();
  console.log("AgentHall deployed to:", address);
  console.log("Agent ID registry:", registry);
  console.log("Network:", hre.network.name);
  // 部署后记下地址：11-26 做 BscScan 源码验证，11-27 主网部署前先报 gas
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
