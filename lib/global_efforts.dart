import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flip_card/flip_card.dart';

class GlobalEffortsPage extends StatelessWidget {
  const GlobalEffortsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Efforts on E-Waste Management'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Section 1: Global E-Waste Recycling Rates with chart as additional content
            FlippableSectionCard(
              title: 'Global E-Waste Recycling Rates',
              description:
              'Recent studies indicate that formal recycling rates remain very low. Reports show a gradual increase from about 15.0% in 2015 to 18.0% in 2020.',
              icon: Icons.trending_up,
              backgroundColor: Colors.lightGreen.shade200,
              additionalContent: Column(
                children: [
                  SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                    'Data from Statista and Global E-Waste Monitor.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Section 2: India's E-Waste Management with chart as additional content
            FlippableSectionCard(
              title: "India's E-Waste Management",
              description:
              'India is one of the fastest-growing e-waste producers. Only about 15% of the e-waste is processed through formal recycling channels, while the vast majority is handled informally.',
              icon: Icons.flag,
              backgroundColor: Colors.lightGreen[300]!,
              additionalContent: Column(
                children: [
                  SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 300,
                        child: IndiaRecyclingChart(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Informal recycling dominates in India.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Section 3: How India Manages E-Waste (no extra details)
            FlippableSectionCard(
              title: 'How India Manages E-Waste',
              description:
              'India employs a mix of methods including formal recycling plants, Extended Producer Responsibility (EPR), awareness campaigns, and public-private partnerships to reduce the environmental impact of e-waste.',
              icon: Icons.settings,
              backgroundColor: Colors.lightGreen.shade200,
            ),
            SizedBox(height: 20),
            // Section 4: What Governments Can Do (no extra details)
            FlippableSectionCard(
              title: 'What Governments Can Do',
              description:
              '• Stricter Enforcement: Implement and enforce e-waste regulations with robust penalties for non-compliance.\n'
                  '• Infrastructure Investment: Increase formal recycling centers and collection points.\n'
                  '• Public Awareness: Educate consumers on proper e-waste disposal and recycling.\n'
                  '• Incentives for Manufacturers: Promote eco-design and product take-back programs.',
              icon: Icons.gavel,
              backgroundColor: Colors.lightGreen[300]!,
            ),
            SizedBox(height: 20),
            // Section 5: Conclusion (no extra details)
            FlippableSectionCard(
              title: 'Conclusion',
              description:
              'Global e-waste recycling remains a significant challenge. Enhanced collaboration among governments, industries, and consumers is essential for a sustainable circular economy.',
              icon: Icons.check_circle,
              backgroundColor: Colors.lightGreen.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

class FlippableSectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Widget? additionalContent;

  const FlippableSectionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    this.additionalContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the flip card in a fixed-size container.
    return SizedBox(
      height: 500, // fixed height for uniformity
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Icon(
                  icon,
                  size: 40,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
        back: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          // If additionalContent is provided, show a tabbed view.
          child: additionalContent != null
              ? DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Colors.green,
                  labelColor: Colors.green[900],
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: "Overview"),
                    Tab(text: "Details"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(25),
                        child: additionalContent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class RecyclingRatesChart extends StatelessWidget {
  // Data derived from sources such as Statista and Global E-Waste Monitor.
  final List<double> recyclingRates = [15.0, 15.8, 16.2, 16.8, 17.4, 18.0];
  final List<int> years = [2015, 2016, 2017, 2018, 2019, 2020];

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      recyclingRates.length,
          (index) => FlSpot(years[index].toDouble(), recyclingRates[index]),
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
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 32,
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(fontSize: 12),
              ),
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
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 15,
            title: "Formal (15%)",
            color: Colors.brown,
            radius: 80,
            titleStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          PieChartSectionData(
            value: 85,
            title: "Informal/Other (85%)",
            color: Colors.lightGreen,
            radius: 80,
            titleStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
