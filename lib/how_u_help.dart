import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/detection_page.dart';

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
            // User Dashboard
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '📍 Location: New Delhi', // Replace with dynamic location
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

            // Earn Rewards Section (Green Container, Animation on Right)
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

            // Locate Nearby Recycling Facilities (Animation on Left)
            _buildSection(
              title: 'Locate Nearby Recycling Facilities',
              description: '🔍 Find nearby certified recycling centers with ease.\n'
                  '📦 Drop off your old electronics or schedule a pickup.\n'
                  '🌱 Ensure proper recycling of materials to reduce waste and pollution.',
              animationPath: 'assets/recycling_facility.json',
              buttonText: 'Find Facilities',
              onPressed: () {
                // TODO: Add navigation to recycling facilities map page
              },
              reverse: true, // Animation on Left
            ),
            SizedBox(height: 30),

            // Participate in E-Drives (Animation on Right)
            _buildSection(
              title: 'Participate in E-Drives',
              description: '📅 Join organized e-waste collection drives in your area.\n'
                  '🤝 Connect with communities supporting sustainable waste management.\n'
                  '🏆 Earn rewards, incentives, and contribute to a cleaner planet.',
              animationPath: 'assets/edrives.json',
              buttonText: 'Join E-Drives',
              onPressed: () {
                // TODO: Add navigation to E-Drives page
              },
              reverse: false, // Animation on Right
            ),
            SizedBox(height: 30),

            // YouTube Video Section
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

  // ✅ Dashboard Info Cards
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
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[800])),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // ✅ Unified Section Builder (Alternating Layout)
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
        color: Colors.green[500], // Green background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: reverse
            ? [
          Expanded(child: Lottie.asset(animationPath, height: 200)), // Animation on Left
          SizedBox(width: 20),
          Expanded(child: _textBlock(title, description, buttonText, onPressed)),
        ]
            : [
          Expanded(child: _textBlock(title, description, buttonText, onPressed)),
          SizedBox(width: 20),
          Expanded(child: Lottie.asset(animationPath, height: 200)), // Animation on Right
        ],
      ),
    );
  }

  // ✅ Text Block with Button
  Widget _textBlock(String title, String description, String buttonText, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
}
