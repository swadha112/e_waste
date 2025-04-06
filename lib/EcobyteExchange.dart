import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Simple data model for a device stock (no category field).
class DeviceStock {
  final String name;
  final String symbol;
  int currentPrice;
  List<double> history;

  DeviceStock(this.name, this.symbol, this.currentPrice, this.history);
}

/// Data model for a transaction.
class Transaction {
  final String orderType; // "Buy" or "Sell"
  final String deviceName;
  final String deviceAge;
  final String quantity;
  final DateTime timestamp;

  Transaction({
    required this.orderType,
    required this.deviceName,
    required this.deviceAge,
    required this.quantity,
    required this.timestamp,
  });
}

class EcoByteExchangePage extends StatefulWidget {
  const EcoByteExchangePage({Key? key}) : super(key: key);

  @override
  State<EcoByteExchangePage> createState() => _EcoByteExchangePageState();
}

class _EcoByteExchangePageState extends State<EcoByteExchangePage> {
  // 10 sample stocks with initial prices & 10 data points each
  // Using more modern device names
  List<DeviceStock> stocks = [
    DeviceStock("iPhone 15", "IPH15", 16000, List.generate(10, (i) => 14000 + i * 200.0)),
    DeviceStock("Galaxy S23", "GS23", 22000, List.generate(10, (i) => 20000 + i * 150.0)),
    DeviceStock("MacBook Pro", "MBP", 35000, List.generate(10, (i) => 33000 + i * 300.0)),
    DeviceStock("Surface Laptop", "SURF", 28000, List.generate(10, (i) => 26000 + i * 250.0)),
    DeviceStock("Pixel 7", "PX7", 19000, List.generate(10, (i) => 17000 + i * 180.0)),
    DeviceStock("iPad Air", "IPAD", 24000, List.generate(10, (i) => 22000 + i * 200.0)),
    DeviceStock("Lenovo Yoga", "LNVY", 21000, List.generate(10, (i) => 19000 + i * 210.0)),
    DeviceStock("OnePlus 11", "OP11", 18000, List.generate(10, (i) => 16000 + i * 180.0)),
    DeviceStock("HP Envy", "HPEN", 26000, List.generate(10, (i) => 24000 + i * 230.0)),
    DeviceStock("Asus ROG", "ASRG", 30000, List.generate(10, (i) => 28000 + i * 220.0)),
  ];

  // A simple trending devices list (non-null fields)
  final List<Map<String, String>> trendingDevices = [
    {
      "name": "iPhone 16",
      "demand": "High",
      "sip": "Available SIP: ₹7000/month",
      "price": "₹1,20,000",
    },
    {
      "name": "Galaxy S23",
      "demand": "Medium",
      "sip": "SIP: ₹4000/month",
      "price": "₹1,22,000",
    },
    {
      "name": "Dell Inspiron",
      "demand": "High",
      "sip": "SIP: ₹3000/month",
      "price": "₹65,000",
    },
  ];

  // SIP simulation
  double invested = 0;
  double targetPrice = 0;
  String targetDevice = "";
  bool hasActiveSIP = false; // whether a SIP is active

  // For separate stock chart
  String? selectedSymbol;
  DeviceStock? selectedStock;

  // Controllers
  final TextEditingController sipController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController deviceAgeController = TextEditingController();

  // Buy/Sell
  String orderType = "Buy";

  // Transactions
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    simulatePriceUpdates();
  }

  // Periodically update prices every 5 seconds, ±200 fluctuation
  void simulatePriceUpdates() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        stocks = stocks.map((stock) {
          final rng = Random();
          final change = rng.nextInt(401) - 200; // ±200
          final newPrice = max(1000, stock.currentPrice + change);
          final newHistory = List<double>.from(stock.history)
            ..removeAt(0)
            ..add(newPrice.toDouble());
          return DeviceStock(stock.name, stock.symbol, newPrice, newHistory);
        }).toList();
      });
      simulatePriceUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pastel green background from your screenshot
    const bgColor = Color(0xFFF3F8F2);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('EcoByte Exchange'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Trending Devices
            _buildTrendingDevicesCard(),
            const SizedBox(height: 16),

            // Market Summary
            _buildMarketSummaryCard(),
            const SizedBox(height: 16),

            // Category Filter
            _buildCategoryFilterRow(),
            const SizedBox(height: 16),

            // SIP Goals
            _buildSIPGoalsCard(),
            const SizedBox(height: 16),

            // Combined Chart
            _buildCombinedChartCard(),
            const SizedBox(height: 20),

            // Separate Stock Chart
            _buildSeparateChartCard(),
            const SizedBox(height: 20),

            // Create SIP button
            _buildCreateSIPButton(),
            const SizedBox(height: 20),

            // SIP simulation
            _buildSIPSimulation(),
            const SizedBox(height: 20),

            // Buy/Sell
            _buildBuySellSimulation(),
            const SizedBox(height: 20),

            // Transaction Dashboard
            _buildDashboard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 1. Trending Devices
  Widget _buildTrendingDevicesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                "Trending Devices",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < trendingDevices.length; i++) ...[
            _buildTrendingDeviceRow(trendingDevices[i]),
            if (i < trendingDevices.length - 1) ...[
              const SizedBox(height: 12),
              const Divider(thickness: 0.5),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTrendingDeviceRow(Map<String, String> device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device["name"] ?? "Unknown Device",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900]),
            ),
            const SizedBox(height: 4),
            Text(
              "Demand: ${device["demand"] ?? "N/A"}\n${device["sip"] ?? ""}",
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
        // Right Price
        Text(
          device["price"] ?? "N/A",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
      ],
    );
  }

  /// 2. Market Summary
  Widget _buildMarketSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                "Market Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Devices Sold: 3.2k this month\nAvg Price Change: +3.7%\nPopular Category: Laptops",
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  /// 3. Category Filter
  final List<String> categories = ["All", "Phones", "Laptops", "Tablets"];
  Widget _buildCategoryFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          bool isSelected = cat == "All";
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                // front-end only
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.green[600] : Colors.green[100],
                foregroundColor: isSelected ? Colors.white : Colors.green[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4. SIP Goals
  Widget _buildSIPGoalsCard() {
    double progress = (targetPrice > 0) ? (invested / targetPrice) : 0;
    if (progress > 1) progress = 1;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                "Your SIP Goals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasActiveSIP)
            const Text("No SIP created yet. Tap 'Create SIP' to start one.", style: TextStyle(color: Colors.grey))
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(targetDevice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${targetPrice.toStringAsFixed(0)}", style: TextStyle(fontSize: 16, color: Colors.green[800], fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Invested: ₹$invested / ₹$targetPrice", style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, color: Colors.green, backgroundColor: Colors.black12),
            if (invested >= targetPrice && targetPrice > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("✅ Goal Reached! Device will be auto-purchased.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
          ],
        ],
      ),
    );
  }

  /// 5. Combined Chart
  Widget _buildCombinedChartCard() {
    // Compute average line across all stocks
    List<FlSpot> spots = _computeCombinedSpots();
    if (spots.isEmpty) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Overall Dynamic Pricing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "This chart shows the average price trend across all listed devices over time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text("₹${value.toInt()}", style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text("T${value.toInt()}", style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _computeCombinedSpots() {
    if (stocks.isEmpty) return [];
    int minLen = stocks.map((s) => s.history.length).reduce(min);
    if (minLen == 0) return [];
    List<DeviceStock> stableStocks = stocks.where((s) => s.history.length >= minLen).toList();
    if (stableStocks.isEmpty) return [];

    // Compute average
    List<double> avgPrices = List.generate(minLen, (i) {
      List<double> pricesAtTime = stableStocks.map((s) => s.history[i]).toList();
      return pricesAtTime.reduce((a, b) => a + b) / pricesAtTime.length;
    });

    return List.generate(minLen, (i) => FlSpot(i.toDouble(), avgPrices[i]));
  }

  /// 6. Separate Stock Chart
  Widget _buildSeparateChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("View Individual Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text("Select a Stock", style: TextStyle(fontSize: 16)),
              value: selectedSymbol,
              isExpanded: true,
              items: stocks.map((DeviceStock stock) {
                return DropdownMenuItem<String>(
                  value: stock.symbol,
                  child: Text(stock.name),
                );
              }).toList(),
              onChanged: (String? newSymbol) {
                setState(() {
                  selectedSymbol = newSymbol;
                  selectedStock = stocks.firstWhere((s) => s.symbol == newSymbol);
                });
              },
            ),
            if (selectedStock != null) ...[
              const SizedBox(height: 20),
              _buildSeparateChart(selectedStock!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeparateChart(DeviceStock stock) {
    List<FlSpot> spots = [];
    for (int i = 0; i < stock.history.length; i++) {
      spots.add(FlSpot(i.toDouble(), stock.history[i]));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text("₹${value.toInt()}", style: const TextStyle(fontSize: 12)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text("T${value.toInt()}", style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Create SIP Button
  Widget _buildCreateSIPButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            final TextEditingController deviceCtrl = TextEditingController();
            final TextEditingController priceCtrl = TextEditingController();

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Create SIP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: deviceCtrl,
                    decoration: const InputDecoration(labelText: "Target Device", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Target Price", border: OutlineInputBorder()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    final newDevice = deviceCtrl.text.trim();
                    final newPrice = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    if (newDevice.isNotEmpty && newPrice > 0) {
                      setState(() {
                        targetDevice = newDevice;
                        targetPrice = newPrice;
                        invested = 0;
                        hasActiveSIP = true;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Create SIP"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("Create SIP", style: TextStyle(fontSize: 18)),
    );
  }

  /// 8. SIP Simulation Card
  Widget _buildSIPSimulation() {
    if (!hasActiveSIP) return const SizedBox();

    double sipProgress = (targetPrice > 0) ? (invested / targetPrice) : 0;
    if (sipProgress > 1) sipProgress = 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SIP for $targetDevice", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Invested: ₹$invested / ₹$targetPrice", style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: sipProgress, color: Colors.green, backgroundColor: Colors.black12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sipController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Add lumpsum to SIP", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    double additional = double.tryParse(sipController.text) ?? 0;
                    setState(() {
                      invested += additional;
                    });
                    sipController.clear();
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
            if (invested >= targetPrice && targetPrice > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("✅ Goal Reached! Device will be auto-purchased.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }

  /// 9. Buy/Sell Simulation
  Widget _buildBuySellSimulation() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Buy/Sell Stocks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: deviceNameController,
              decoration: const InputDecoration(labelText: "Device Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deviceAgeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Device Age (years)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: orderType,
                  items: ["Buy", "Sell"].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) {
                    setState(() {
                      orderType = val!;
                    });
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Quantity", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _executeOrder,
                child: Text("$orderType Now", style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _executeOrder() {
    final device = deviceNameController.text.trim();
    final age = deviceAgeController.text.trim();
    final qty = quantityController.text.trim();

    if (device.isEmpty || age.isEmpty || qty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    setState(() {
      transactions.add(Transaction(
        orderType: orderType,
        deviceName: device,
        deviceAge: age,
        quantity: qty,
        timestamp: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$orderType order executed for $qty units of $device (Age: $age yrs).")),
    );

    deviceNameController.clear();
    deviceAgeController.clear();
    quantityController.clear();
  }

  /// 10. Transaction Dashboard
  Widget _buildDashboard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.lightGreenAccent,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transaction History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (transactions.isEmpty)
              const Text("No transactions yet.", style: TextStyle(color: Colors.black))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("${tx.orderType} - ${tx.deviceName}", style: const TextStyle(color: Colors.black)),
                    subtitle: Text("Age: ${tx.deviceAge} yrs, Qty: ${tx.quantity}", style: const TextStyle(color: Colors.black87)),
                    trailing: Text(
                      "${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
