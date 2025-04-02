async function main() {
    // Get the contract factory for ChipTracker
    const ChipTracker = await ethers.getContractFactory("ChipTracker");
    
    console.log("Deploying ChipTracker...");
    // Deploy the contract
    const chipTracker = await ChipTracker.deploy();
    // Wait for the deployment to be confirmed
    await chipTracker.waitForDeployment();
    
    console.log("ChipTracker deployed to:", chipTracker.target);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  