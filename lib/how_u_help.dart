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
            // New Section: Disposal Options
            // -------------------------------------------------
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
                              backgroundColor: Colors.white, foregroundColor: Colors.green),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => DetectionPage()));
                          },
                          child: Text(' Start with Object Detection', textAlign: TextAlign.center,),
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
                              backgroundColor: Colors.white, foregroundColor: Colors.green),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => EDrivesPage()));
                          },
                          child: Text('Schedule a Drive'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
            Lottie.asset(animationPath, height: 50),
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
                    color: Colors.green[900],
                  ),
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
}
