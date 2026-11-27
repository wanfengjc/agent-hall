const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AgentHall", function () {
  async function deployFixture() {
    const [deployer, holder, stranger] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("MockAgentIdRegistry");
    const registry = await Registry.deploy();
    const AgentHall = await ethers.getContractFactory("AgentHall");
    const hall = await AgentHall.deploy(await registry.getAddress());
    await registry.setBalance(holder.address, 1); // holder 有 Agent ID
    return { hall, registry, deployer, holder, stranger };
  }

  it("非持有者领徽章应 revert", async function () {
    const { hall, stranger } = await deployFixture();
    await expect(hall.connect(stranger).claimBadge()).to.be.revertedWithCustomError(
      hall,
      "NotAgentIdHolder"
    );
  });

  it("持有者可领 1 枚徽章，再领应 revert", async function () {
    const { hall, holder } = await deployFixture();
    await hall.connect(holder).claimBadge();
    expect(await hall.badgeOf(holder.address)).to.equal(1);
    await expect(hall.connect(holder).claimBadge()).to.be.revertedWithCustomError(
      hall,
      "BadgeAlreadyClaimed"
    );
  });

  it("签到：当天第二次应 revert；次日签到连续天数 +1", async function () {
    const { hall, holder } = await deployFixture();
    await hall.connect(holder).claimBadge();
    await hall.connect(holder).checkIn();
    expect(await hall.streakOf(holder.address)).to.equal(1);
    expect(await hall.hasCheckedInToday(holder.address)).to.equal(true);
    await expect(hall.connect(holder).checkIn()).to.be.revertedWithCustomError(
      hall,
      "AlreadyCheckedInToday"
    );
    await ethers.provider.send("evm_increaseTime", [24 * 3600]);
    await ethers.provider.send("evm_mine");
    await hall.connect(holder).checkIn();
    expect(await hall.streakOf(holder.address)).to.equal(2);
  });

  it("断签后重新累计；7 天连续签到升到 2 级", async function () {
    const { hall, holder } = await deployFixture();
    await hall.connect(holder).claimBadge();
    await hall.connect(holder).checkIn();
    await ethers.provider.send("evm_increaseTime", [3 * 24 * 3600]); // 断签 2 天
    await ethers.provider.send("evm_mine");
    await hall.connect(holder).checkIn();
    expect(await hall.streakOf(holder.address)).to.equal(1);
    for (let i = 0; i < 6; i++) {
      await ethers.provider.send("evm_increaseTime", [24 * 3600]);
      await ethers.provider.send("evm_mine");
      await hall.connect(holder).checkIn();
    }
    expect(await hall.streakOf(holder.address)).to.equal(7);
    expect(await hall.levelOf(holder.address)).to.equal(2);
  });

  it("徽章不可转让：transferFrom 应 revert", async function () {
    const { hall, holder, stranger } = await deployFixture();
    await hall.connect(holder).claimBadge();
    await expect(
      hall.connect(holder).transferFrom(holder.address, stranger.address, 1)
    ).to.be.revertedWithCustomError(hall, "Soulbound");
  });
});
