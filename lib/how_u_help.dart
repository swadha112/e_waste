import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
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
      initialVideoId: 'HELP_VIDEO_ID', // Replace with actual YouTube video ID
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
            // User Dashboard with Lottie animations
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
                    'Location: New Delhi', // Replace with dynamic location
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

            // Object Detection Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetectionPage()),
                  );
                },
                child: Text('Try Object Detection'),
              ),
            ),
            SizedBox(height: 20),

            // Contribution Cards Section
            Text(
              'Ways You Can Contribute',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _contributionCard(
                Icons.recycling,
                'Recycle Responsibly',
                'Take your old gadgets to certified e-waste recycling centers.'
            ),
            _contributionCard(
                Icons.favorite,
                'Donate Electronics',
                'Give functional used devices to those in need instead of discarding them.'
            ),
            _contributionCard(
                Icons.event,
                'Join Collection Drives',
                'Participate in local e-waste drives to help gather old electronics safely.'
            ),
            _contributionCard(
                Icons.shopping_bag,
                'Buy Refurbished',
                'Choose refurbished gadgets to lower demand for new electronics production.'
            ),
            _contributionCard(
                Icons.campaign,
                'Spread Awareness',
                'Educate your community about responsible e-waste disposal methods.'
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

  // Widget for dashboard info cards with Lottie animation
  Widget _infoCard(String title, String value, String animationPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
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

  // Widget for contribution info cards
  Widget _contributionCard(IconData icon, String title, String description) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
