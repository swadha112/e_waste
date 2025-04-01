import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  final String userContact;

  const DashboardPage({Key? key, required this.userContact}) : super(key: key);

  // A helper widget to build an info card for the header
  Widget _infoCard(String title, String value, String lottieAsset) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Lottie animation (if you have the asset; otherwise you can use an Icon)
            Container(
              height: 50,
              child: Lottie.asset(lottieAsset, fit: BoxFit.contain),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget to build a section given a title and a Firestore stream.
  Widget buildSection({
    required String sectionTitle,
    required Stream<QuerySnapshot> stream,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('No $sectionTitle found.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                // For Scheduled Drop Offs, use centerName and timestamp instead.
                if (sectionTitle == "Scheduled Drop Offs") {
                  final centerName = data['centerName'] ?? 'N/A';
                  final scheduled = data['timestamp'] != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                      : 'N/A';
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(centerName),
                      subtitle: Text("Scheduled: $scheduled"),
                    ),
                  );
                } else {
                  final name = data['name'] ?? 'N/A';
                  final status = data['status'] ?? 'pending';
                  final scheduledDateTime = data['scheduledDateTime'] ?? 'N/A';
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text("Status: $status\nScheduled: $scheduledDateTime"),
                    ),
                  );
                }
              },
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[400];
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Swadha!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '📍 Location: Mumbai',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _infoCard('Points', '1250', 'assets/points.json'),
                      _infoCard('Carbon Footprint', '2.5kg', 'assets/carbon.json'),
                      _infoCard('Times Recycled', '10', 'assets/recycled.json'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Section 1: Collective E-Drives (pickup_requests)
            buildSection(
              sectionTitle: "Collective E-Drives",
              stream: FirebaseFirestore.instance
                  .collection('pickup_requests')
                  .where('contact', isEqualTo: userContact)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
            ),
            // Section 2: Personal Pickup (Scheduled_pickup)
            buildSection(
              sectionTitle: "Personal Pickup",
              stream: FirebaseFirestore.instance
                  .collection('Scheduled_pickup')
                  .where('contact', isEqualTo: userContact)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
            ),
            // Section 3: Scheduled Drop Offs (scheduled_dropoff)
            buildSection(
              sectionTitle: "Scheduled Drop Offs",
              stream: FirebaseFirestore.instance
                  .collection('scheduled_dropoff')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
            ),
          ],
        ),
      ),
    );
  }
}
