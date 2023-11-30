import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { writeFileSync, readFileSync } from "fs";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployAccount: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
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

  await deploy("Account", {
    from: deployer,
    log: true,

    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract
  const account = await hre.ethers.getContract("Account", deployer);

  const argumentsJson = JSON.parse(readFileSync("./arguments.json", "utf8"));

  argumentsJson["ERC6551AccountImpl"] = account.address;

  writeFileSync("./arguments.json", JSON.stringify(argumentsJson, null, 2), "utf8");
};

export default deployAccount;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags Account
deployAccount.tags = ["Account"];
