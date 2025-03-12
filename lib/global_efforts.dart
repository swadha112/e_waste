import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GlobalEffortsPage extends StatelessWidget {
  const GlobalEffortsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the current theme's text style for consistency.
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Efforts on E-Waste Management'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Global E-Waste Recycling Rates'),
            SizedBox(height: 10),
            _buildSectionDescription(
              'Recent studies indicate that formal recycling rates remain very low. For example, reports show a gradual increase from about 15.0% in 2015 to 18.0% in 2020. The line chart below represents these trends over recent years.',
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300,
                  child: RecyclingRatesChart(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Note: Data from sources such as Statista and the Global E-Waste Monitor.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Divider(height: 40, thickness: 1.5),
            _buildSectionTitle("India's E-Waste Management"),
            SizedBox(height: 10),
            _buildSectionDescription(
              'India is one of the fastest-growing e-waste producers. However, only about 15% of the e-waste is processed through formal recycling channels, with the vast majority handled informally. The pie chart below illustrates these figures.',
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300,
                  child: IndiaRecyclingChart(),
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildSectionDescription(
              'India’s formal recycling sector is small but growing. Informal recycling, while providing livelihoods, often lacks environmental and safety controls.',
            ),
            Divider(height: 40, thickness: 1.5),
            _buildSectionTitle('How India Manages E-Waste'),
            SizedBox(height: 10),
            _buildSectionDescription(
              'India employs a mix of methods, including formal recycling plants, Extended Producer Responsibility (EPR), awareness campaigns, and public-private partnerships. These efforts aim to reduce the environmental impact of e-waste while promoting safer recycling practices.',
            ),
            Divider(height: 40, thickness: 1.5),
            _buildSectionTitle('What Governments Can Do'),
            SizedBox(height: 10),
            _buildSectionDescription(
              '• Stricter Enforcement: Implement and enforce existing e-waste regulations with robust penalties for non-compliance.\n'
              '• Infrastructure Investment: Increase formal recycling centers and collection points, especially in underserved areas.\n'
              '• Public Awareness: Launch campaigns to educate consumers on the benefits of proper e-waste disposal and recycling.\n'
              '• Incentives for Manufacturers: Promote eco-design and product take-back programs through subsidies and tax incentives.',
            ),
            Divider(height: 40, thickness: 1.5),
            _buildSectionTitle('Conclusion'),
            SizedBox(height: 10),
            _buildSectionDescription(
              'Global e-waste recycling remains a significant challenge. Enhanced collaboration among governments, industries, and consumers is essential to drive improvements in recycling rates and develop a sustainable circular economy for electronics.',
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green[900],
      ),
    );
  }

  Widget _buildSectionDescription(String description) {
    return Text(
      description,
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
    );
  }
}

class RecyclingRatesChart extends StatelessWidget {
  // Data derived from sources such as Statista and Global E-Waste Monitor.
  final List<double> recyclingRates = [15.0, 15.8, 16.2, 16.8, 17.4, 18.0];
  final List<int> years = [2015, 2016, 2017, 2018, 2019, 2020];

  @override
  Widget build(BuildContext context) {
    // Create data points for the line chart.
    final spots = List.generate(
      recyclingRates.length,
      (index) => FlSpot(
        years[index].toDouble(),
        recyclingRates[index],
      ),
    );

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(show: true),
            barWidth: 4,
          ),
        ],
        minX: 2015,
        maxX: 2020,
        minY: 0,
        maxY: 30,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 40,
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 32,
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }
}

class IndiaRecyclingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Pie chart representing that formal recycling accounts for 15% and informal/other for 85%.
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 15,
            title: "Formal (15%)",
            color: Colors.blue,
            radius: 80,
            titleStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          PieChartSectionData(
            value: 85,
            title: "Informal/Other (85%)",
            color: Colors.grey,
            radius: 80,
            titleStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
