import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Data model for a device stock.
class DeviceStock {
  final String name;
  final String symbol;
  int currentPrice;
  List<double> history;

  DeviceStock(this.name, this.symbol, this.currentPrice, this.history);
}

// Data model for a transaction.
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
  // 10 sample stocks with initial prices & history (10 data points each)
  List<DeviceStock> stocks = [
    DeviceStock("iPhone 12", "IPH12", 15000, List.generate(10, (i) => 13000 + i * 200.0)),
    DeviceStock("MacBook Air 2018", "MBA18", 28000, List.generate(10, (i) => 25000 + i * 300.0)),
    DeviceStock("Samsung S21", "SS21", 18000, List.generate(10, (i) => 16000 + i * 150.0)),
    DeviceStock("Google Pixel 5", "GP5", 20000, List.generate(10, (i) => 18000 + i * 220.0)),
    DeviceStock("Dell XPS 13", "DX13", 30000, List.generate(10, (i) => 27000 + i * 250.0)),
    DeviceStock("iPad Pro", "IPDP", 25000, List.generate(10, (i) => 23000 + i * 180.0)),
    DeviceStock("Lenovo ThinkPad", "LTP", 22000, List.generate(10, (i) => 20000 + i * 210.0)),
    DeviceStock("Sony Xperia", "SX", 17000, List.generate(10, (i) => 15000 + i * 190.0)),
    DeviceStock("HP Spectre", "HPS", 26000, List.generate(10, (i) => 24000 + i * 230.0)),
    DeviceStock("Asus ZenBook", "AZB", 24000, List.generate(10, (i) => 22000 + i * 200.0)),
  ];

  // SIP simulation variables.
  double invested = 0;          // Total lumpsum added so far.
  double targetPrice = 0;       // Set by the user when creating a SIP.
  String targetDevice = "";     // Set by the user when creating a SIP.
  bool hasActiveSIP = false;

  // For separate stock chart.
  String? selectedSymbol;
  DeviceStock? selectedStock;

  // Controllers.
  final TextEditingController sipController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController deviceAgeController = TextEditingController();

  // Order type: "Buy" or "Sell".
  String orderType = "Buy";

  // List of executed transactions.
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    simulatePriceUpdates();
  }

  // Simulate price updates for each stock every 3 seconds.
  void simulatePriceUpdates() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        stocks = stocks.map((stock) {
          final rng = Random();
          final change = rng.nextInt(1000) - 500;
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

  /// Convert a list of prices into a list of FlSpot.
  List<FlSpot> pricesToSpots(List<double> prices) {
    List<FlSpot> spots = [];
    for (int i = 0; i < prices.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i].toDouble()));
    }
    return spots;
  }

  /// Build a combined line chart showing the average price across all stocks.
  /// This chart explains the dynamic pricing concept to the user.
  Widget _buildCombinedChart() {
    if (stocks.isEmpty) return const SizedBox();

    // Determine the minimum history length among all stocks.
    int minLen = stocks.map((s) => s.history.length).reduce(min);
    if (minLen == 0) return const SizedBox();

    // Filter stocks that have at least minLen history.
    List<DeviceStock> stableStocks = stocks.where((s) => s.history.length >= minLen).toList();
    if (stableStocks.isEmpty) return const SizedBox();

    // Calculate average price for each time index.
    List<double> avgPrices = List.generate(minLen, (i) {
      List<double> pricesAtTime = stableStocks.map((s) => s.history[i]).toList();
      return pricesAtTime.reduce((a, b) => a + b) / pricesAtTime.length;
    });

    List<FlSpot> spots = pricesToSpots(avgPrices);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Overall Dynamic Pricing Stock Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "This chart shows the average price trend across all listed devices over time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text("₹${value.toInt()}",
                            style: const TextStyle(color: Colors.black, fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text("T${value.toInt()}",
                            style: const TextStyle(color: Colors.black, fontSize: 10)),
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
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

  /// Build a line chart for a single selected stock.
  Widget _buildSeparateChart(DeviceStock stock) {
    List<FlSpot> spots = pricesToSpots(stock.history);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${stock.name} Price Trend",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text("₹${value.toInt()}",
                            style: const TextStyle(color: Colors.black, fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text("T${value.toInt()}",
                            style: const TextStyle(color: Colors.black, fontSize: 10)),
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
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

  /// Build the SIP simulation card (shown only if a SIP is active).
  Widget _buildSIPSimulation() {
    if (!hasActiveSIP) return const SizedBox();

    double sipProgress = (targetPrice > 0) ? (invested / targetPrice) : 0;
    if (sipProgress > 1) sipProgress = 1;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SIP for $targetDevice",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text(
              "Invested: ₹$invested / ₹$targetPrice",
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: sipProgress,
              color: Colors.green,
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sipController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Add lumpsum to SIP",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "✅ Goal Reached! $targetDevice will be auto-purchased.",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      ),
    );
  }

  /// Create SIP button & dialog.
  Widget _buildCreateSIPButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController deviceCtrl = TextEditingController();
              final TextEditingController priceCtrl = TextEditingController();

              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Create SIP", style: TextStyle(color: Colors.black)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: deviceCtrl,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Target Device",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Target Price",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
        child: const Text("Create SIP"),
      ),
    );
  }

  /// Build the Buy/Sell simulation widget.
  Widget _buildBuySellSimulation() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buy/Sell Stocks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            // Device name input.
            TextField(
              controller: deviceNameController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Device Name",
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // Device age input.
            TextField(
              controller: deviceAgeController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Device Age (in years)",
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            // Row for Buy/Sell and quantity.
            Row(
              children: [
                DropdownButton<String>(
                  value: orderType,
                  style: const TextStyle(color: Colors.black),
                  items: <String>['Buy', 'Sell'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
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
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Quantity",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Execute order button.
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                final device = deviceNameController.text.trim();
                final age = deviceAgeController.text.trim();
                final qty = quantityController.text.trim();

                if (device.isEmpty || age.isEmpty || qty.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all fields."),
                    ),
                  );
                  return;
                }

                // Add a transaction to our dashboard.
                Transaction newTx = Transaction(
                  orderType: orderType,
                  deviceName: device,
                  deviceAge: age,
                  quantity: qty,
                  timestamp: DateTime.now(),
                );
                setState(() {
                  transactions.add(newTx);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "$orderType order executed for $qty units of $device (Age: $age yrs).",
                    ),
                  ),
                );

                // Optionally, clear the fields.
                deviceNameController.clear();
                deviceAgeController.clear();
                quantityController.clear();
              },
              child: Text("$orderType Now"),
            )
          ],
        ),
      ),
    );
  }

  /// Build a dashboard that shows SIP progress (if any) and transaction history.
  Widget _buildDashboard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            if (hasActiveSIP)
              Text(
                "Active SIP: $targetDevice - Invested: ₹$invested / ₹$targetPrice",
                style: const TextStyle(color: Colors.black),
              ),
            const SizedBox(height: 10),
            const Text(
              "Transactions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            transactions.isEmpty
                ? const Text("No transactions yet.", style: TextStyle(color: Colors.black))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Transaction tx = transactions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("${tx.orderType} - ${tx.deviceName}", style: const TextStyle(color: Colors.black)),
                  subtitle: Text("Age: ${tx.deviceAge} yrs, Qty: ${tx.quantity}"),
                  trailing: Text(
                    "${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EcoByte Exchange'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Combined average line chart.
            _buildCombinedChart(),
            const SizedBox(height: 20),

            // Separate stock chart.
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.green, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Show Separate Stock Chart",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    DropdownButton<String>(
                      hint: const Text("Select a Stock", style: TextStyle(color: Colors.black)),
                      value: selectedSymbol,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black),
                      items: stocks.map((DeviceStock stock) {
                        return DropdownMenuItem<String>(
                          value: stock.symbol,
                          child: Text(stock.name, style: const TextStyle(color: Colors.black)),
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
            ),
            const SizedBox(height: 20),

            // Create SIP button.
            _buildCreateSIPButton(),
            const SizedBox(height: 20),

            // SIP simulation card (if active).
            _buildSIPSimulation(),
            const SizedBox(height: 20),

            // Buy/Sell simulation widget.
            _buildBuySellSimulation(),
            const SizedBox(height: 20),

            // Dashboard.
            _buildDashboard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
