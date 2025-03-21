import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'global_map_section.dart';  // Import the GlobalMapSection widget

class HarmfulEffectsPage extends StatefulWidget {
  @override
  _HarmfulEffectsPageState createState() => _HarmfulEffectsPageState();
}

class _HarmfulEffectsPageState extends State<HarmfulEffectsPage> {
  late YoutubePlayerController _youtubeController;

  // Markers for the map (adjust coordinates as needed)
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('NorthAmerica'),
      position: LatLng(45.0, -100.0),
      infoWindow: InfoWindow(title: 'North America: 10 Mt'),
    ),
    Marker(
      markerId: MarkerId('Europe'),
      position: LatLng(50.0, 10.0),
      infoWindow: InfoWindow(title: 'Europe: 12 Mt'),
    ),
    Marker(
      markerId: MarkerId('Asia'),
      position: LatLng(30.0, 100.0),
      infoWindow: InfoWindow(title: 'Asia: 30 Mt'),
    ),
    Marker(
      markerId: MarkerId('Africa'),
      position: LatLng(0.0, 20.0),
      infoWindow: InfoWindow(title: 'Africa: 5 Mt'),
    ),
    Marker(
      markerId: MarkerId('LatinAmerica'),
      position: LatLng(-15.0, -60.0),
      infoWindow: InfoWindow(title: 'Latin America: 7 Mt'),
    ),
  };

  @override
  void initState() {
    super.initState();
    // Using a valid YouTube video ID (replace with your choice)
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'a1Y73sPHKxw',
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
        title: Text('Harmful Effects of E-Waste'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: What is E-Waste?
            Text(
              'What is E-Waste?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'E-Waste, or electronic waste, refers to discarded electronic devices such as computers, smartphones, TVs, and other gadgets. '
                  'Improper disposal of these devices releases toxic substances into the environment.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Display multiple images below "What is E-Waste?" (increased size)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildImage('assets/ewaste1.jpg'),
                  SizedBox(width: 10),
                  _buildImage('assets/ewaste2.jpg'),
                  SizedBox(width: 10),
                  _buildImage('assets/ewaste3.jpg'),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Section 2: Why Do We Generate So Much E-Waste?
            Text(
              'Why Do We Generate So Much E-Waste?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildWhyEWasteSection(),
            SizedBox(height: 30),
            // Section 3: Global E-Waste Generation
            Text(
              'Global E-Waste Generation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'According to the Global E-Waste Monitor, the world generated about 53.6 million metric tonnes of e-waste in 2019. '
                  'Consumption of electronics and short product lifecycles continue to drive this number upward.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Global E-Waste Bar Chart with labels on the x-axis.
            SizedBox(
              height: 300,
              child: GlobalEWasteChart(),
            ),
            SizedBox(height: 30),
            // Section 4: Indian E-Waste Generation
            Text(
              'Indian E-Waste Generation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'India is rapidly growing in e-waste production. A large informal recycling sector leads to unsafe recycling practices and hazardous exposure for many workers.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Indian E-Waste Pie Chart.
            SizedBox(
              height: 300,
              child: IndiaEWasteChart(),
            ),
            SizedBox(height: 30),
            // Section 5: Global Map with Markers using Google Maps API
            Text(
              'Global E-Waste by Region',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Now using the imported GlobalMapSection
            Container(
              height: 300,
              child: GlobalMapSection(markers: _markers),  // Using GlobalMapSection
            ),
            SizedBox(height: 30),
            // Section 6: YouTube Video in a box
            Text(
              'Watch this video to see the impact of e-waste on our environment:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                aspectRatio: 16 / 9,
              ),
            ),
            SizedBox(height: 30),
            // Section 7: Carbon Footprint
            Text(
              'Understanding the Carbon Footprint',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'A carbon footprint measures the total greenhouse gas emissions caused by an individual, organization, or product. '
                  'The lifecycle of electronic devices—from manufacturing to disposal—contributes to carbon emissions. '
                  'By recycling and extending device lifespans, we can help reduce this footprint.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(child: _buildImage('assets/cf.webp')),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper method to build an image widget with increased size.
  Widget _buildImage(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        height: 200,
        width: 300,
        fit: BoxFit.cover,
      ),
    );
  }

  // Helper widget for the "Why Do We Generate So Much E-Waste?" section.
  Widget _buildWhyEWasteSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Reasons presented in two rows.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEwasteReason(
                icon: Icons.update,
                title: 'Rapid Tech Advancements',
                description: 'New devices quickly replace older ones.',
              ),
              _buildEwasteReason(
                icon: Icons.add_shopping_cart,
                title: 'Consumer Demand',
                description: 'Frequent upgrades drive waste.',
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEwasteReason(
                icon: Icons.build,
                title: 'Planned Obsolescence',
                description: 'Products are designed for limited lifespans.',
              ),
              _buildEwasteReason(
                icon: Icons.settings_backup_restore,
                title: 'Lack of Repair',
                description: 'Repair is often too costly or difficult.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEwasteReason({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Chart Widgets ---

// Global E-Waste Bar Chart with sample data and axis labels.
class GlobalEWasteChart extends StatelessWidget {
  // Sample data (in million metric tonnes)
  final List<double> values = [33.8, 44.7, 53.6, 57.0, 60.0];
  final List<String> years = ['2010', '2014', '2019', '2021', '2023'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 70,
        barGroups: List.generate(values.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index >= 0 && index < years.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      years[index],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  );
                }
                return Container();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 12),
                );
              },
              reservedSize: 28,
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// Indian E-Waste Pie Chart with updated percentages.
class IndiaEWasteChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 70,
            title: "Informal",
            color: Colors.red,
            radius: 80,
            titleStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: 20,
            title: "Landfills",
            color: Colors.orange,
            radius: 80,
            titleStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: 10,
            title: "Authorized",
            color: Colors.green,
            radius: 80,
            titleStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
