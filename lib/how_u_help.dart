import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/detection_page.dart';
import 'package:e_waste/recycling_center.dart';
import 'package:e_waste/edrives.dart';

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
      initialVideoId: 'FoSc5h4yxHc', // Replace with actual YouTube video ID
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // -------------------------------------------------
            // 1) User Dashboard
            // -------------------------------------------------
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
                    'Hello, Swadha!', // Replace with dynamic username
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '📍 Location: Mumbai', // Replace with dynamic location
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

            // -------------------------------------------------
            // 2) Ways You Can Contribute (RIGHT BELOW DASHBOARD)
            // -------------------------------------------------
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

            // -------------------------------------------------
            // 3) Earn Rewards Section (Green Container)
            // -------------------------------------------------
            _buildSection(
              title: 'Earn Rewards for Recycling',
              description: '📸 Scan an object to detect its recyclable and non-recyclable components.\n'
                  '💰 Get price estimation for recycling valuable materials.\n'
                  '🎁 Earn incentives for contributing to recycling centers.\n'
                  '🌍 Reduce your carbon footprint by ensuring responsible disposal.',
              animationPath: 'assets/detection.json',
              buttonText: 'Try Object Detection',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetectionPage()));
              },
              reverse: false, // Animation on Right
            ),
            SizedBox(height: 30),

            // -------------------------------------------------
            // 4) Locate Nearby Recycling Facilities
            // -------------------------------------------------
            _buildSection(
              title: 'Locate Nearby Recycling Facilities',
              description: '🔍 Find nearby certified recycling centers with ease.\n'
                  '📦 Drop off your old electronics or schedule a pickup.\n'
                  '🌱 Ensure proper recycling of materials to reduce waste and pollution.',
              animationPath: 'assets/recycling_facility.json',
              buttonText: 'Find Facilities',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EwasteCentersPage()));
              },
              reverse: true, // Animation on Left
            ),
            SizedBox(height: 30),

            // -------------------------------------------------
            // 5) Participate in E-Drives
            // -------------------------------------------------
            _buildSection(
              title: 'Participate in E-Drives',
              description: '📅 Join organized e-waste collection drives in your area.\n'
                  '🤝 Connect with communities supporting sustainable waste management.\n'
                  '🏆 Earn rewards, incentives, and contribute to a cleaner planet.',
              animationPath: 'assets/edrives.json',
              buttonText: 'Join E-Drives',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EDrivesPage()));
              },
              reverse: false, // Animation on Right
            ),
            SizedBox(height: 30),

            // -------------------------------------------------
            // 6) YouTube Video Section
            // -------------------------------------------------
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

  // -----------------------------
  // Dashboard Info Cards
  // -----------------------------
  Widget _infoCard(String title, String value, String animationPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            Lottie.asset(animationPath, height: 50), // Lottie animation
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // Section Builder (Green Box)
  // -----------------------------
  Widget _buildSection({
    required String title,
    required String description,
    required String animationPath,
    required String buttonText,
    required VoidCallback onPressed,
    required bool reverse,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[800], // Green background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: reverse
            ? [
          // Animation on Left
          Expanded(child: Lottie.asset(animationPath, height: 200)),
          SizedBox(width: 20),
          Expanded(child: _textBlock(title, description, buttonText, onPressed)),
        ]
            : [
          // Animation on Right
          Expanded(child: _textBlock(title, description, buttonText, onPressed)),
          SizedBox(width: 20),
          Expanded(child: Lottie.asset(animationPath, height: 200)),
        ],
      ),
    );
  }

  // -----------------------------
  // Text Block with Button
  // -----------------------------
  Widget _textBlock(String title, String description, String buttonText, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(description, style: TextStyle(fontSize: 14, color: Colors.white70)),
        SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green),
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }

  // -----------------------------
  // "Ways You Can Contribute" Item
  // -----------------------------
  Widget _buildContributionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // or a light shade
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
          // Icon on the left
          Icon(
            icon,
            size: 30,
            color: Colors.green,
          ),
          SizedBox(width: 16),
          // Title + Subtitle in a column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title in bold
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 6),
                // Subtitle
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
}
