import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  final String userContact;

  const DashboardPage({Key? key, required this.userContact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Stream that listens to the pickup_requests where the 'contact' field matches the user's contact.
    final pickupRequestsStream = FirebaseFirestore.instance
        .collection('pickup_requests')
        .where('contact', isEqualTo: userContact)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup Requests Dashboard"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pickupRequestsStream,
        builder: (context, snapshot) {
          // Check for errors.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Show a loading indicator while waiting for data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Check if there is any data.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pickup requests found."));
          }
          // Build a list view of the pickup requests.
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'N/A';
              final String status = data['status'] ?? 'pending';
              final String scheduledDateTime = data['scheduledDateTime'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(
                    "Status: $status\nScheduled: $scheduledDateTime",
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
