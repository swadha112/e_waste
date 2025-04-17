// lib/widgets/market_summary.dart
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class MarketSummaryWidget extends StatelessWidget {
  MarketSummaryWidget({Key? key}) : super(key: key);
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: firebaseService.getMarketSummary(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text("No data found.");
        }
        final summary = snapshot.data!;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Market Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Average Price: ₹${summary['avgPrice'].toStringAsFixed(0)}"),
                Text("Total Devices: ${summary['totalDevices']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
