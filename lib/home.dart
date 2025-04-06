import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
 import 'package:e_waste/harmful_effects.dart';
 import 'package:e_waste/global_efforts.dart';
 import 'package:e_waste/how_u_help.dart';
 import 'dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Helper to build each section card with a shade of green
  static Widget _buildSectionCard(
      BuildContext context, {
        required Color color,
        required String lottieAsset,
        required String title,
        required String description,
        required VoidCallback onPressed,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Lottie.asset(lottieAsset, height: 120),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
              ),
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No appBar as requested
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Section with gradient overlay
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/EcoByte.png'),
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
                    children: const [
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
            const SizedBox(height: 30),

            // Harmful Effects Section (Green shade)
            _buildSectionCard(
              context,
              color: Colors.green.shade300,
              lottieAsset: 'assets/effects.json',
              title: 'Harmful Effects of E-Waste',
              description:
              'E-waste releases toxic substances like lead, mercury, and cadmium into the environment, contaminating soil and water.',
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => HarmfulEffectsPage()));
              },
            ),

            // Global Efforts Section (Green shade)
            _buildSectionCard(
              context,
              color: Colors.green.shade400,
              lottieAsset: 'assets/gov.json',
              title: 'Global Efforts on E-Waste Management',
              description:
              'Governments are enforcing stricter regulations and companies are adopting eco-friendly disposal methods.',
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalEffortsPage()));
              },
            ),

            // How Can You Help Section (Green shade)
            _buildSectionCard(
              context,
              color: Colors.green.shade500,
              lottieAsset: 'assets/recycle.json',
              title: 'How Can You Help?',
              description:
              'Recycle old electronics, donate used gadgets, participate in e-waste drives, and buy refurbished items.',
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => HowCanYouHelpPage()));
              },
            ),

            // Dashboard Section (Green shade)
            _buildSectionCard(
              context,
              color: Colors.green.shade400,
              lottieAsset: 'assets/dashboard.json', // Replace with your dashboard animation
              title: 'Dashboard',
              description:
              'View your pickup requests and manage your recycling progress.',
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage(userContact: '9769338461')));
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
