import 'package:flutter/services.dart' show rootBundle;
import 'package:web3dart/web3dart.dart';

class ChipTrackerContract {
  final DeployedContract contract;
  final Web3Client client;
  final EthereumAddress contractAddress;

  ChipTrackerContract(this.client, this.contractAddress, this.contract);

  // Load the contract from the ABI file stored in assets
  static Future<ChipTrackerContract> load(Web3Client client, EthereumAddress contractAddress) async {
    final abiString = await rootBundle.loadString('assets/chip_tracker.abi');
    final contract = DeployedContract(
      ContractAbi.fromJson(abiString, "ChipTracker"),
      contractAddress,
    );
    return ChipTrackerContract(client, contractAddress, contract);
  }

  // Calls the registerChip function of the contract
  Future<String> registerChip(String uid, BigInt manufactureDate, Credentials credentials) async {
    final registerFunction = contract.function("registerChip");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: registerFunction,
        parameters: [uid, manufactureDate],
      ),
      chainId: 11155111, // Adjust this for your network (e.g., Sepolia)
    );
    return txHash;
  }

  // Calls the recordDisposal function of the contract
  Future<String> recordDisposal(String uid, BigInt disposalDate, Credentials credentials) async {
    final disposalFunction = contract.function("recordDisposal");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: disposalFunction,
        parameters: [uid, disposalDate],
      ),
      chainId: 11155111,
    );
    return txHash;
  }

  // Calls the recordTransferForReuse function of the contract
  Future<String> recordTransferForReuse(String uid, BigInt transferDate, EthereumAddress newManufacturer, Credentials credentials) async {
    final transferFunction = contract.function("recordTransferForReuse");
    final txHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [uid, transferDate, newManufacturer],
      ),
      chainId: 11155111,
    );
    return txHash;
  }
}
