import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/harmful_effects.dart';
import 'package:e_waste/global_efforts.dart';
import 'package:e_waste/how_u_help.dart';
import 'dashboard.dart'; // Make sure dashboard.dart is in your project

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: add an AppBar if desired
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with gradient overlay and adjusted title alignment
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/ewasteBg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EcoByte',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Let’s Reduce, Reuse, and Recycle E-Waste!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Awareness Sections with Arrow Icons for Navigation
            _buildInfoSection(
              context: context,
              title: 'Harmful Effects of E-Waste',
              content:
              'E-waste releases toxic substances like lead, mercury, and cadmium into the environment, affecting human health, contaminating soil and water, and disrupting ecosystems.',
              animationPath: 'assets/effects.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HarmfulEffectsPage()),
                );
              },
            ),
            _buildInfoSection(
              context: context,
              title: 'Global Efforts on E-Waste Management',
              content:
              'Governments are enforcing stricter regulations, companies are adopting eco-friendly disposal, and e-waste recycling plants are growing globally.',
              animationPath: 'assets/gov.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GlobalEffortsPage()),
                );
              },
            ),
            _buildInfoSection(
              context: context,
              title: 'How Can You Help?',
              content:
              '1. Recycle old electronics responsibly.\n'
                  '2. Donate used gadgets to those in need.\n'
                  '3. Participate in e-waste collection drives.\n'
                  '4. Buy refurbished electronics to reduce demand for new production.',
              animationPath: 'assets/recycle.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HowCanYouHelpPage()),
                );
              },
            ),
            SizedBox(height: 30),
            // Dashboard button to check pickup_requests
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(
                        userContact: '9769338461', // Replace with actual user contact if available
                      ),
                    ),
                  );
                },
                child: Text("Go to Dashboard"),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required String content,
    required String animationPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with arrow icon indicating navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward, color: Colors.green),
              ],
            ),
            SizedBox(height: 10),
            Text(content, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Center(child: Lottie.asset(animationPath, height: 200)),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
