// lib/widgets/stock_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/device_stock.dart';
import '../services/firebase_service.dart';

class StockChartWidget extends StatelessWidget {
  final String category;
  const StockChartWidget({Key? key, this.category = "All"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<DeviceStock>>(
      stream: firebaseService.getStocks(category),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.black));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }
        final stocks = snapshot.data;
        if (stocks == null || stocks.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text("No data for this category", style: TextStyle(color: Colors.black))),
          );
        }

        // find the shortest history length
        final minLen = stocks.map((s) => s.history.length).reduce((a, b) => a < b ? a : b);

        // build spots for average price over time
        final spots = List<FlSpot>.generate(minLen, (i) {
          final avg = stocks.map((s) => s.history[i]).reduce((a, b) => a + b) / stocks.length;
          return FlSpot(i.toDouble(), avg);
        });

        // determine y-axis bounds
        final prices = spots.map((e) => e.y).toList();
        final minY = prices.reduce((a, b) => a < b ? a : b) * 0.95;
        final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.05;

        return Card(
          color: Colors.white,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Combined Stock Chart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text("Price (₹)", style: TextStyle(color: Colors.black, fontSize: 12)),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (maxY - minY) / 5,
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text("Time", style: TextStyle(color: Colors.black, fontSize: 12)),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (minLen / 5).floorToDouble().clamp(1, double.infinity),
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
