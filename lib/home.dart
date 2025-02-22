import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:e_waste/detection_page.dart'; // Make sure to import the detection page correctly

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                // Background Image
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/ewasteBg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Title & Slogan
                Positioned(
                  top: 150,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Try Object Detection Button
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Object Detection Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetectionPage()),
                  );
                },
                child: Text("Try Object Detection"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                ),
              ),
            ),

            // E-Waste Statistics Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Waste Statistics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: EWasteStatisticsChart(),
                  ),
                ],
              ),
            ),

            // Harmful Effects Section
            _buildInfoSection(
              title: 'Harmful Effects of E-Waste',
              content: 'E-waste releases toxic substances like lead and mercury into the environment, affecting human health and ecosystems.',
              animationPath: 'assets/effects.json',
            ),

            // Government Actions Section
            _buildInfoSection(
              title: 'What is Being Done?',
              content: 'Countries and governments worldwide, including India, are implementing policies for responsible e-waste management.',
              animationPath: 'assets/gov.json',
            ),

            // How You Can Help Section
            _buildInfoSection(
              title: 'How Can You Help?',
              content: 'Dispose of e-waste at authorized centers, recycle electronics, and spread awareness to promote sustainable practices.',
              animationPath: 'assets/recycle.json',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content, required String animationPath}) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Center(
            child: Lottie.asset(animationPath, height: 200),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class EWasteStatisticsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Text('0');
                if (value == 20) return Text('20M');
                if (value == 40) return Text('40M');
                if (value == 60) return Text('60M');
                if (value == 80) return Text('80M');
                if (value == 100) return Text('100M');
                return Text('');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text('2022 Total');
                  case 1:
                    return Text('2022 Recycled');
                  case 2:
                    return Text('2030 Projected');
                  case 3:
                    return Text('2030 Recycled');
                  default:
                    return Text('');
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 62, color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(5))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 13.8, color: Colors.green, width: 20, borderRadius: BorderRadius.circular(5))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 82, color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(5))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 16.4, color: Colors.green, width: 20, borderRadius: BorderRadius.circular(5))]),
        ],
      ),
    );
  }
}
