import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:e_waste/detection_page.dart'; // Ensure detection_page.dart exists in your project

class HowCanYouHelpPage extends StatefulWidget {
  @override
  _HowCanYouHelpPageState createState() => _HowCanYouHelpPageState();
}

class _HowCanYouHelpPageState extends State<HowCanYouHelpPage> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    // Replace with an actual YouTube video ID with tips on efficient e-waste management.
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'HELP_VIDEO_ID',
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
            Text(
              'Steps to Contribute',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Recycle old electronics responsibly.\n'
              '2. Donate used gadgets to those in need.\n'
              '3. Participate in local e-waste collection drives.\n'
              '4. Buy refurbished electronics to reduce new production demands.\n'
              '5. Spread awareness about e-waste management in your community.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
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
