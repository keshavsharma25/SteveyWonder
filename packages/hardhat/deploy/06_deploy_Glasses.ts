import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { readFileSync } from "fs";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployGlasses: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const argumentsJson = JSON.parse(readFileSync("./arguments.json", "utf8"));

  await deploy("Glasses", {
    from: deployer,
    log: true,
    // constructor Args
    args: [deployer, argumentsJson.SteveyWonder, argumentsJson.ERC6551Registry, argumentsJson.ERC6551AccountImpl],
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract
  // const Glasses = await hre.ethers.getContract("Glasses", deployer);
};

export default deployGlasses;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags Glasses
deployGlasses.tags = ["Glasses"];
