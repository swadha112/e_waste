// lib/blockchain_service.dart
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class BlockchainService {
  // Replace with your Sepolia RPC URL (e.g., from Infura)
  final String rpcUrl = "https://sepolia.infura.io/v3/e577457effe540769facdd8d06c8a025";
  final Web3Client client;

  BlockchainService()
      : client = Web3Client("https://sepolia.infura.io/v3/e577457effe540769facdd8d06c8a025", http.Client());

  void dispose() {
    client.dispose();
  }
}
