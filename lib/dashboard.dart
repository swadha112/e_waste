import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'track_chip_page.dart'; // Ensure this file exists and implements your tracking map page

class DashboardPage extends StatelessWidget {
  final String userContact;

  const DashboardPage({Key? key, required this.userContact}) : super(key: key);

  // Info card widget for header (white background with Lottie icon)
  Widget _infoCard(String title, String value, String lottieAsset) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // white info card background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Lottie.asset(lottieAsset, fit: BoxFit.contain),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ Section 1: Pickup Requests ------------------
  Widget _buildPickupRequestsSection(String userContact) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('contact', isEqualTo: userContact)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Text('No Pickup Requests scheduled.');
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'N/A';
            final dateString = data['timestamp'] != null
                ? DateFormat('dd MMM yyyy')
                .format((data['timestamp'] as Timestamp).toDate())
                : 'N/A';

            final buildingName = data['buildingName'] ?? 'N/A';
            final contact = data['contact'] ?? 'N/A';
            final pickupFor = data['pickupFor'] ?? 'N/A';
            final rewardPoints =
            data['rewardPoints'] != null ? data['rewardPoints'].toString() : '0';
            final status = data['status'] ?? 'Pending';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.green,
                backgroundColor: Colors.green,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                title: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Scheduled: $dateString',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.business, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Building: $buildingName',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Contact: $contact',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.assignment, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Pickup For: $pickupFor',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.stars, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Reward Points: $rewardPoints',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------ Section 2: Scheduled Pickup ------------------
  Widget _buildScheduledPickupSection(String userContact) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Scheduled_pickup')
          .where('contact', isEqualTo: userContact)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Text('No Scheduled Pickups.');
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'N/A';
            final dateString = data['timestamp'] != null
                ? DateFormat('dd MMM yyyy')
                .format((data['timestamp'] as Timestamp).toDate())
                : 'N/A';

            // Use selectedCenterAddress and selectedCenterName from Firebase
            final streetAddress = data['streetAddress'] ?? 'N/A';
            final contact = data['contact'] ?? 'N/A';
            final centerAddress = data['centerAddress'] ?? 'N/A';
            final centerName = data['centerTitle'] ?? 'N/A';
            final deviceName = data['deviceName'] ?? 'N/A';
            final devicePrice =
            data['devicePrice'] != null ? data['devicePrice'].toString() : '0';
            final status = data['status'] ?? 'Pending';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.green,
                backgroundColor: Colors.green,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                title: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Scheduled: $dateString',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Street Address
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Street Address: $streetAddress',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Contact
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Contact: $contact',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Center Address (with wrapping)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Center: $centerName\n$centerAddress',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Device Details
                        Row(
                          children: [
                            Icon(Icons.devices, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Device: $deviceName',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Price: ₹$devicePrice',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        // Show "Track Chip" button only if status is "successful"
                        if (status.toLowerCase() == "successful")
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to TrackChipPage passing the center address
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TrackChipPage(
                                      centerAddress: centerAddress,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text("Track Chip"),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------ Section 3: Scheduled Drop Offs ------------------
  Widget _buildScheduledDropOffSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scheduled_dropoff')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Text('No Scheduled Drop Offs.');
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Swadha';
            final dateString = data['timestamp'] != null
                ? DateFormat('dd MMM yyyy')
                .format((data['timestamp'] as Timestamp).toDate())
                : 'N/A';

            final centreAddress = data['centerAddress'] ?? 'N/A';
            final objectChosen = data['objectChosen'] ?? 'N/A';
            final price =
            data['price'] != null ? data['price'].toString() : '0';
            final status = data['status'] ?? 'Pending';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.green,
                backgroundColor: Colors.green,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                title: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Scheduled: $dateString',
                  style: TextStyle(color: Colors.white),
                ),
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Center Address: $centreAddress',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.devices, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Object: $objectChosen',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Price: ₹$price',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------ Main Build Method ------------------
  @override
  Widget build(BuildContext context) {
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
            // Dashboard header with greeting, location, and info cards
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
            // Section 1: Pickup Requests
            Text(
              'Pickup Requests',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800]),
            ),
            _buildPickupRequestsSection(userContact),
            SizedBox(height: 20),
            // Section 2: Scheduled Pickup
            Text(
              'Scheduled Pickup',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800]),
            ),
            _buildScheduledPickupSection(userContact),
            SizedBox(height: 20),
            // Section 3: Scheduled Drop Offs
            Text(
              'Scheduled Drop Offs',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800]),
            ),
            _buildScheduledDropOffSection(),
          ],
        ),
      ),
    );
  }
}
