// lib/widgets/trending_devices.dart
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/device_stock.dart';

class TrendingDevicesWidget extends StatelessWidget {
  TrendingDevicesWidget({Key? key}) : super(key: key);
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DeviceStock>>(
      stream: firebaseService.getTrendingDevices(),
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
        List<DeviceStock> trending = snapshot.data!;
        if(trending.isEmpty) {
          return const Text("No trending devices.");
        }
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Trending Devices",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trending.length,
                  itemBuilder: (context, index) {
                    final device = trending[index];
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(
                          "Category: ${device.category} | Price: ₹${device.currentPrice}"),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
