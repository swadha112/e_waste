import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/detection_page.dart';
import 'package:e_waste/recycling_center.dart';
import 'package:e_waste/edrives.dart';

/// Model for Scheduled Disposal (from 'scheduled_disposals' collection)
class ScheduledDisposal {
  final String centerName;
  final String centerAddress;
  final String objectChosen;
  final double price;
  final DateTime timestamp;
  final String status;

  ScheduledDisposal({
    required this.centerName,
    required this.centerAddress,
    required this.objectChosen,
    required this.price,
    required this.timestamp,
    required this.status,
  });

  factory ScheduledDisposal.fromDocument(Map<String, dynamic> doc) {
    return ScheduledDisposal(
      centerName: doc['centerName'] ?? 'Unknown',
      centerAddress: doc['centerAddress'] ?? 'No address',
      objectChosen: doc['objectChosen'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      status: doc['status'] ?? 'Pending',
    );
  }
}

/// Model for Pickup Request (E‑Drive) from 'pickup_requests' collection
class PickupRequestDashboard {
  final String name;
  final String contact;
  final DateTime scheduledDateTime;
  final String pickupFor;
  final String status;

  PickupRequestDashboard({
    required this.name,
    required this.contact,
    required this.scheduledDateTime,
    required this.pickupFor,
    required this.status,
  });

  factory PickupRequestDashboard.fromDocument(Map<String, dynamic> doc) {
    // Assuming scheduledDateTime is saved as an ISO8601 string.
    return PickupRequestDashboard(
      name: doc['name'] ?? '',
      contact: doc['contact'] ?? '',
      scheduledDateTime: doc['scheduledDateTime'] != null
          ? DateTime.parse(doc['scheduledDateTime'])
          : DateTime.now(),
      pickupFor: doc['pickupFor'] ?? '',
      status: doc['status'] ?? 'Pending',
    );
  }
}

class HowCanYouHelpPage extends StatefulWidget {
  @override
  _HowCanYouHelpPageState createState() => _HowCanYouHelpPageState();
}

class _HowCanYouHelpPageState extends State<HowCanYouHelpPage> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'FoSc5h4yxHc',
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  /// Stream builder for Scheduled Disposals
  Widget _buildScheduledDisposalsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scheduled_disposals')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Text('No disposals scheduled yet.');
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final disposal = ScheduledDisposal.fromDocument(data);
            final statusText = disposal.status == "Pending"
                ? "Pickup Pending"
                : "Successful";
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(disposal.centerName),
                subtitle: Text(
                  '${disposal.centerAddress}\n📦 ${disposal.objectChosen} • ₹${disposal.price.toStringAsFixed(2)}\n🕒 ${disposal.timestamp.toLocal()}\n📌 Status: $statusText',
                ),
                isThreeLine: true,
                leading: Icon(Icons.location_on, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  /// Stream builder for Pickup Requests (E-Drive)
  Widget _buildPickupRequestsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Text('No E-Drive scheduled yet.');
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final pickup = PickupRequestDashboard.fromDocument(data);
            final statusText = pickup.status == "Pending"
                ? "Pickup Pending"
                : "Successful";
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(pickup.name),
                subtitle: Text(
                  'Contact: ${pickup.contact}\nScheduled: ${pickup.scheduledDateTime.toLocal()}\nPickup For: ${pickup.pickupFor}\nStatus: $statusText',
                ),
                isThreeLine: true,
                leading: Icon(Icons.drive_eta, color: Colors.blue),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoCard(String title, String value, String animationPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2)
          ],
        ),
        child: Column(
          children: [
            Lottie.asset(animationPath, height: 50),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800]),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.green,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[900]),
                ),
                SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[400];
    return Scaffold(
      appBar: AppBar(
        title: Text('How Can You Help'),
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
                    'Hello, Swadha!', // Replace with dynamic username if needed
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            // Scheduled Disposals Section
            Text(
              'Your Scheduled Disposals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 10),
            _buildScheduledDisposalsSection(),

            SizedBox(height: 20),

            // E-Drive / Pickup Requests Section
            Text(
              'Your Scheduled E-Drive',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 10),
            _buildPickupRequestsSection(),

            SizedBox(height: 20),

            // Ways to Contribute
            Text(
              'Ways You Can Contribute',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            _buildContributionItem(
              icon: Icons.recycling,
              title: 'Recycle Responsibly',
              subtitle: 'Take your old gadgets to certified e-waste recycling centers.',
            ),
            _buildContributionItem(
              icon: Icons.volunteer_activism,
              title: 'Donate Electronics',
              subtitle: 'Give functional used devices to those in need instead of discarding them.',
            ),
            _buildContributionItem(
              icon: Icons.group_work,
              title: 'Join Collection Drives',
              subtitle: 'Participate in local e-waste drives to help gather old electronics safely.',
            ),
            _buildContributionItem(
              icon: Icons.handshake,
              title: 'Buy Refurbished',
              subtitle: 'Choose refurbished gadgets to lower demand for new electronics production.',
            ),
            _buildContributionItem(
              icon: Icons.campaign,
              title: 'Spread Awareness',
              subtitle: 'Educate your community about responsible e-waste disposal methods.',
            ),

            SizedBox(height: 30),

            // Disposal Options
            Text(
              'Looking for a way to dispose?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // Personal Disposal Card
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Lottie.asset('assets/personal.json', height: 100),
                        SizedBox(height: 10),
                        Text(
                          'Personal Disposal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetectionPage()),
                            );
                          },
                          child: Text('Start with Object Detection'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // Collective Disposal Card
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Lottie.asset('assets/collective.json', height: 100),
                        SizedBox(height: 10),
                        Text(
                          'Collective Disposal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SchedulePickupPage()),
                            );
                          },
                          child: Text('Schedule a Drive'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // YouTube Section
            Text(
              'Watch this video for tips on efficient e-waste management:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
