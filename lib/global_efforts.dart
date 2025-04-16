import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GlobalEffortsPage extends StatelessWidget {
  const GlobalEffortsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar for navigation.
      appBar: AppBar(
        title: const Text('Global Efforts on E-Waste Management'),
        backgroundColor: Colors.green,
      ),
      // Background set to a cream/white color.
      //backgroundColor: const Color(0xFFFFF8E1), // Light cream.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            GlobalRatesSection(),
            SizedBox(height: 32),
            IndiaRatesSection(),
            SizedBox(height: 32),
            HowIndiaManagesSection(),
            SizedBox(height: 32),
            WhatGivtsDoSection(),
            SizedBox(height: 32),
            ConclusionSection(),
          ],
        ),
      ),
    );
  }
}

class GlobalRatesSection extends StatelessWidget {
  const GlobalRatesSection({Key? key}) : super(key: key);

  // Custom beige color.
  static const Color beigeColor = Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two equal blocks with a gap.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Heading block (green) with icon.
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.public, size: 36, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Global E-Waste',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right: Content block (beige) with icon.
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: beigeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, size: 36, color: Colors.black87),
                      SizedBox(height: 8),
                      Text(
                        'Recycling Rates: Recent studies indicate formal recycling rates remain low, with a gradual increase from about 15.0% in 2015 to 18.0% in 2020.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Line chart below the row.
        SizedBox(
          height: 300,
          child: RecyclingRatesChart(),
        ),
      ],
    );
  }
}

class IndiaRatesSection extends StatelessWidget {
  const IndiaRatesSection({Key? key}) : super(key: key);

  // Custom beige color.
  static const Color beigeColor = Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two equal blocks with a gap.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Heading block (beige) with icon.
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: beigeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.flag, size: 36, color: Colors.black87),
                      SizedBox(height: 8),
                      Text(
                        "India's E-Waste",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right: Content block (green) with icon.
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, size: 36, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Management: India is one of the fastest-growing e-waste producers. Only about 15% is processed through formal recycling channels, while most is handled informally.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Pie chart below the row.
        SizedBox(
          height: 300,
          child: IndiaRecyclingChart(),
        ),
      ],
    );
  }
}

class HowIndiaManagesSection extends StatelessWidget {
  const HowIndiaManagesSection({Key? key}) : super(key: key);

  // Custom beige color.
  static const Color beigeColor = Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Heading block (green) with icon.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.settings, size: 36, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'How India Manages E-Waste',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right: Content block (beige) with icon.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: beigeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info, size: 36, color: Colors.black87),
                  SizedBox(height: 8),
                  Text(
                    'India employs a mix of formal recycling plants, Extended Producer Responsibility (EPR), public awareness campaigns, and public-private partnerships to manage e-waste effectively.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatGivtsDoSection extends StatelessWidget {
  const WhatGivtsDoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We'll manually arrange two rows.
    // Define colors.
    final Color greenColor = Colors.green;
    final Color beigeColor = const Color(0xFFF5F5DC);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full-width heading in green.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'What Governments Do',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        // First row: left cell green, right cell beige.
        Row(
          children: [
            // Left cell: green.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Stricter Enforcement",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right cell: beige.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: beigeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Infrastructure Investment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: left cell beige, right cell green.
        Row(
          children: [
            // Left cell: beige.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: beigeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Public Awareness",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right cell: green.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Incentives for Manufacturers",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ConclusionSection extends StatelessWidget {
  const ConclusionSection({Key? key}) : super(key: key);

  // Custom beige color.
  static const Color beigeColor = Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Heading block in beige with icon.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: beigeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.announcement, size: 36, color: Colors.black87),
                  SizedBox(height: 8),
                  Text(
                    'Conclusion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right: Content block in green with icon.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check, size: 36, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Enhanced collaboration among governments, industries, and consumers is vital for sustainable e-waste management and a circular economy.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Line Chart widget for global recycling rates.
class RecyclingRatesChart extends StatelessWidget {
  RecyclingRatesChart({Key? key}) : super(key: key);

  // Sample data.
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
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 32,
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12),
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

// Sample Pie Chart widget for India recycling breakdown.
class IndiaRecyclingChart extends StatelessWidget {
  const IndiaRecyclingChart({Key? key}) : super(key: key);

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
            titleStyle: const TextStyle(
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
            titleStyle: const TextStyle(
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
