import 'package:flutter/services.dart' show rootBundle;
import 'package:web3dart/web3dart.dart';

class ChipTrackerContract {
  final DeployedContract contract;
  final Web3Client client;
  final EthereumAddress contractAddress;

  ChipTrackerContract(this.client, this.contractAddress, this.contract);

  // Load the contract from the ABI file stored in assets
  static Future<ChipTrackerContract> load(
      Web3Client client,
      EthereumAddress contractAddress
      ) async {
    // 1. Load the ABI string
    final abiString = await rootBundle.loadString('assets/chip_tracker.abi');
    // 2. Create a DeployedContract instance
    final deployed = DeployedContract(
      ContractAbi.fromJson(abiString, "ChipTracker"),
      contractAddress,
    );
    return ChipTrackerContract(client, contractAddress, deployed);
  }

  // ---------------------------------------------------------------------------
  // registerChip(string _uid, uint256 _manufactureDate)
  Future<String> registerChip(
      String uid,
      BigInt manufactureDate,
      Credentials credentials,
      ) async {
    final function = contract.function("registerChip");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          uid,
          manufactureDate,
        ],
      ),
      chainId: 11155111, // e.g. Sepolia
    );
    return txHash;
  }

  // ---------------------------------------------------------------------------
  // recordDisposal(string _uid, uint256 _disposalDate, string _disposalLocation)
  Future<String> recordDisposal(
      String uid,
      BigInt disposalDate,
      String disposalLocation,
      Credentials credentials,
      ) async {
    final function = contract.function("recordDisposal");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          uid,
          disposalDate,
          disposalLocation, // MISSING before; now fixed
        ],
      ),
      chainId: 11155111,
    );
    return txHash;
  }

  // ---------------------------------------------------------------------------
  // recordDisintegration(string _uid, uint256 _disintegrationDate, string _disintegrationLocation)
  Future<String> recordDisintegration(
      String uid,
      BigInt disintegrationDate,
      String disintegrationLocation,
      Credentials credentials,
      ) async {
    final function = contract.function("recordDisintegration");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          uid,
          disintegrationDate,
          disintegrationLocation,
        ],
      ),
      chainId: 11155111,
    );
    return txHash;
  }

  // ---------------------------------------------------------------------------
  // recordTransferForReuse(
  //   string _uid,
  //   uint256 _transferDate,
  //   address _newManufacturer,
  //   string _manufacturerLocation
  // )
  Future<String> recordTransferForReuse(
      String uid,
      BigInt transferDate,
      EthereumAddress newManufacturer,
      String manufacturerLocation,
      Credentials credentials,
      ) async {
    final function = contract.function("recordTransferForReuse");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          uid,
          transferDate,
          newManufacturer,
          manufacturerLocation, // MISSING before; now fixed
        ],
      ),
      chainId: 11155111,
    );
    return txHash;
  }
}
