import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/harmful_effects.dart';
import 'package:e_waste/global_efforts.dart';
import 'package:e_waste/how_u_help.dart';
import 'dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Define a custom palette for the sections
  final Color harmfulColor = const Color(0xFFA5C882); // Sage green
  final Color globalEffortsColor = const Color(0xFFBFD8B8); // Soft green
  final Color helpColor = const Color(0xFFC2BA9C); // Beige-green
  final Color dashboardColor = const Color(0xFFD0B8A8); // Warm beige

  // Helper to build each section card with custom colors
  static Widget _buildSectionCard(
      BuildContext context, {
        required Color cardColor,
        required String lottieAsset,
        required String title,
        required String description,
        required VoidCallback onPressed,
      }) {
    // Use a dark brown for text to contrast with the light background
    const textColor = Color(0xFF4E342E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
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
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5DC), // Cream/Beige button
                foregroundColor: textColor,
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
    // Instantiate our custom palette values
    final harmful = harmfulColor;
    final globalEfforts = helpColor;
    final help = harmfulColor;
    final dashboard = helpColor;

    return Scaffold(
      // No appBar; using a custom back bar on the hero image
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Section with gradient overlay and back bar
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
                // Back Bar positioned at the top left
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

            // Harmful Effects Section (using custom sage green)
            _buildSectionCard(
              context,
              cardColor: harmful,
              lottieAsset: 'assets/effects.json',
              title: 'Harmful Effects of E-Waste',
              description:
              'E-waste releases toxic substances like lead, mercury, and cadmium into the environment, contaminating soil and water.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  HarmfulEffectsPage()),
                );
              },
            ),

            // Global Efforts Section (using soft green)
            _buildSectionCard(
              context,
              cardColor: globalEfforts,
              lottieAsset: 'assets/gov.json',
              title: 'Global Efforts on E-Waste Management',
              description:
              'Governments are enforcing stricter regulations and companies are adopting eco-friendly disposal methods.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GlobalEffortsPage()),
                );
              },
            ),

            // How Can You Help Section (using beige-green)
            _buildSectionCard(
              context,
              cardColor: help,
              lottieAsset: 'assets/recycle.json',
              title: 'How Can You Help?',
              description:
              'Recycle old electronics, donate used gadgets, participate in e-waste drives, and buy refurbished items.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HowCanYouHelpPage()),
                );
              },
            ),

            // Dashboard Section (using warm beige)
            _buildSectionCard(
              context,
              cardColor: dashboard,
              lottieAsset: 'assets/dashboard.json', // Replace with your dashboard animation asset
              title: 'Dashboard',
              description:
              'View your pickup requests and manage your recycling progress.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage(userContact: '9769338461')),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
