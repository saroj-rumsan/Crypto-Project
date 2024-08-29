import * as dotenv from "dotenv";
import { commonLib } from "./_common";
dotenv.config();

const contractName = ["RahatToken", "C2CProject"];

const rahatTokenDetails = {
  name: "USD Coin",
  symbol: "USDC",
  decimals: 18,
};
class DeploymentSetup extends commonLib {
  constructor() {
    super();
  }

  public async deployC2CContracts() {
    const deployerAccount = this.getDeployerWallet();

    console.log("----------Deploying Rahat Token-------------------");
    const TokenContract = await this.deployContract("RahatToken", [
      rahatTokenDetails.name,
      rahatTokenDetails.symbol,
      deployerAccount.address,
      rahatTokenDetails.decimals,
    ]);

    console.log({
      TokenContract: TokenContract.contract.target,
      blockNumber: TokenContract.blockNumber,
    });

    console.log("----------Deploying C2C Project Contract-------------------");
    const C2CProjectContract = await this.deployContract("C2CProject", [
      "C2C Project",
    ]);
    console.log({
      C2CProjectContract: C2CProjectContract.contract.target,
      blockNumber: C2CProjectContract.blockNumber,
    });
  }
}

async function main() {
  const deploymentSetup = new DeploymentSetup();
  await deploymentSetup.deployC2CContracts();
}
main().catch((error) => {
  console.error(error);
  process.exit(1);
});
