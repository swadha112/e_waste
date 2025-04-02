require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

  module.exports = {
    defaultNetwork: "hardhat",
    solidity: "0.8.28",
    networks: {
      hardhat: {
        // Local in-memory network; no private keys required.
      },
      sepolia: {
        url: "https://sepolia.infura.io/v3/e577457effe540769facdd8d06c8a025", 
        accounts: ["0x752330b88119f45ced36027b3f10ce92c900ab2f423d08780308ee11e135cd5b"] 
      }
    }
  };
