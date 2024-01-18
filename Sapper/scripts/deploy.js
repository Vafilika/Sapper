// We require the Hardhat Runtime Environment explicitly here. This is optional
const hre = require("hardhat");
const {ethers} = require("hardhat")

async function main() {
  const [owner, otherAccount] = await ethers.getSigners();

  const SaperCertificate = await ethers.getContractFactory("SaperCertificate");
  const saperCertificate = await SaperCertificate.deploy();

  const Saper = await ethers.getContractFactory("Saper");
  const saper = await Saper.deploy(await saperCertificate.getAddress());
  await saperCertificate.connect(owner).setSaper(await saper.getAddress());

  console.log(saperCertificate.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
