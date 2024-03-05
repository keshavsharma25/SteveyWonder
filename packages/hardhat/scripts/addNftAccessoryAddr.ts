import { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import { TShirt, Pants, Shoes, Glasses, Hairs, SteveyWonder } from "../typechain-types";

async function main() {
  // const argumentsJson = JSON.parse(fs.readFileSync("../arguments.json").toLocaleString());

  const deployer = (await ethers.getSigners())[0];

  const tshirt = (await ethers.getContract("TShirt", deployer)) as TShirt;
  const pants = (await ethers.getContract("Pants", deployer)) as Pants;
  const shoes = (await ethers.getContract("Shoes", deployer)) as Shoes;
  const glasses = (await ethers.getContract("Glasses", deployer)) as Glasses;
  const hairs = (await ethers.getContract("Hairs", deployer)) as Hairs;
  const steveyWonder = (await ethers.getContract("SteveyWonder", deployer)) as SteveyWonder;

  await steveyWonder.connect(deployer).addNftAccessoryAddr(tshirt.address);
  await steveyWonder.connect(deployer).addNftAccessoryAddr(pants.address);
  await steveyWonder.connect(deployer).addNftAccessoryAddr(shoes.address);
  await steveyWonder.connect(deployer).addNftAccessoryAddr(glasses.address);
  await steveyWonder.connect(deployer).addNftAccessoryAddr(hairs.address);
  console.log("Added accessories to SteveyWonder");
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
