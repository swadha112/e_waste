import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/sip_plan.dart';
import '../services/firebase_service.dart';
import '../widgets/stock_chart.dart';
import '../models/device_stock.dart';

class EcoByteExchangePage extends StatefulWidget {
  const EcoByteExchangePage({Key? key}) : super(key: key);

  @override
  _EcoByteExchangePageState createState() => _EcoByteExchangePageState();
}

class _EcoByteExchangePageState extends State<EcoByteExchangePage> {
  final FirebaseService _service = FirebaseService();
  final String _userId = 'demoUser';

  // Filters
  String _trendingCategory = 'All';
  String _chartCategory    = 'All';

  // Buy/Sell controllers
  final _deviceCtrl = TextEditingController();
  final _qtyCtrl    = TextEditingController();
  String _orderType = 'Buy';

  // SIP controller
  final _sipCtrl    = TextEditingController();

  @override
  void dispose() {
    _deviceCtrl.dispose();
    _qtyCtrl.dispose();
    _sipCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_deviceCtrl.text.isEmpty || _qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final tx = TransactionModel(
      orderType:  _orderType,
      deviceName: _deviceCtrl.text,
      deviceAge:  'N/A',
      quantity:   int.tryParse(_qtyCtrl.text) ?? 1,
      timestamp:  DateTime.now(),
    );
    await _service.addTransaction(tx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_orderType order for ${_deviceCtrl.text} submitted!')),
    );
    _deviceCtrl.clear();
    _qtyCtrl.clear();
  }

  void _showCreateSIP() {
    final device = TextEditingController();
    final price  = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Create SIP', style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: device,
              decoration: const InputDecoration(
                labelText: 'Target Device',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Price',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final dev = device.text.trim();
              final tgt = double.tryParse(price.text.trim()) ?? 0;
              if (dev.isEmpty || tgt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid values')),
                );
                return;
              }
              final plan = SIPPlan(
                targetDevice:      dev,
                targetPrice:       tgt,
                invested:          0,
                status:            'active',
                creationTimestamp: DateTime.now(),
              );
              await _service.setUserSIPPlan(_userId, plan);
              Navigator.pop(ctx);
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Text(text,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.black)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _buildTrending() {
    return StreamBuilder<List<DeviceStock>>(
      stream: _service.getTrendingDevices(),
      builder: (ctx, snap) {
        final theme = Theme.of(context).textTheme;
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));
        var list = snap.data!;
        if (_trendingCategory != 'All') {
          list = list.where((d) => d.category == _trendingCategory).toList();
        }
        if (list.length > 3) list = list.take(3).toList();

        return _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.local_fire_department, 'Trending Devices'),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  Text('No trending in $_trendingCategory.',
                      style: theme.bodyMedium!.copyWith(color: Colors.grey))
                else
                  ...list.map((d) => Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(d.name, style: theme.titleMedium),
                        subtitle: Text('₹${d.currentPrice}', style: theme.bodyMedium!.copyWith(color: Colors.green)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                      const Divider(height: 1),
                    ],
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    final cats = ['All', 'Phone', 'Laptop', 'Tablet', 'TV', 'Earphone', 'Oven', 'Smartwatch'];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: cats.map((c) {
        final sel = c == _trendingCategory;
        return ChoiceChip(
          label: Text(c),
          selected: sel,
          selectedColor: Colors.green,
          onSelected: (_) => setState(() => _trendingCategory = c),
          labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
          backgroundColor: Colors.grey[200],
        );
      }).toList(),
    );
  }

  Widget _buildMarketSummary() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _service.getMarketSummary(),
      builder: (ctx, snap) {
        final theme = Theme.of(context).textTheme.bodyMedium!;
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));
        final m = snap.data!;
        return _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle(Icons.insights, 'Market Summary'),
              const SizedBox(height: 12),
              Text('Devices Sold: 3.2k this month', style: theme.copyWith(color: Colors.black)),
              Text('Avg Price Change: +3.7%',      style: theme.copyWith(color: Colors.black)),
              Text('Popular Category: Laptops',   style: theme.copyWith(color: Colors.black)),
              const SizedBox(height: 8),
              Text('Avg Price: ₹${(m['avgPrice'] as double).toStringAsFixed(0)}',
                  style: theme.copyWith(color: Colors.grey)),
              Text('Total Devices: ${m['totalDevices']}',
                  style: theme.copyWith(color: Colors.grey)),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildStockChartSection() {
    return Column(children: [
      _buildCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _sectionTitle(Icons.show_chart, 'Price Trends'),
            const SizedBox(height: 12),
            StockChartWidget(category: _chartCategory),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Category:', style: TextStyle(color: Colors.black)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _chartCategory,
                items: ['All', 'Phone', 'Laptop', 'Tablet', 'TV', 'Earphone', 'Oven', 'Smartwatch']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _chartCategory = v!),
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildSIPSection() {
    final theme = Theme.of(context).textTheme;
    return StreamBuilder<SIPPlan?>(
      stream: _service.getUserSIPPlan(_userId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }
        final plan = snap.data;
        return _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle(Icons.savings, 'Your SIP Goals'),
              const SizedBox(height: 12),
              if (plan == null)
                Text('No SIP created. Tap the top icon to begin.',
                    style: theme.bodyMedium!.copyWith(color: Colors.grey))
              else ...[
                Text(plan.targetDevice, style: theme.titleMedium!.copyWith(color: Colors.black)),
                const SizedBox(height: 4),
                Text('Target: ₹${plan.targetPrice.toStringAsFixed(0)}',
                    style: theme.bodyMedium),
                const SizedBox(height: 4),
                Text('Invested: ₹${plan.invested}',
                    style: theme.bodyMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                    value: plan.invested / plan.targetPrice,
                    color: Colors.green,
                    backgroundColor: Colors.black12),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _sipCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Add to SIP',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      final add = double.tryParse(_sipCtrl.text) ?? 0;
                      if (add > 0 && plan != null) {
                        final newInv = plan.invested + add;
                        await _service.updateSipInvested(_userId, newInv);
                        _sipCtrl.clear();
                        if (newInv >= plan.targetPrice) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('Congratulations!', style: TextStyle(color: Colors.black)),
                              content: const Text(
                                'You are eligible to get your dream device!',
                                style: TextStyle(color: Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK', style: TextStyle(color: Colors.green)),
                                )
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ]),
              ]
            ]),
          ),
        );
      },
    );
  }

  Widget _buildBuySell() {
    final theme = Theme.of(context).textTheme;
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle(Icons.shopping_cart, 'Buy/Sell'),
          const SizedBox(height: 12),
          Row(children: [
            DropdownButton<String>(
              value: _orderType,
              items: ['Buy', 'Sell'].map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => setState(() => _orderType = v!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _deviceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _submitOrder,
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildTransactions() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle(Icons.history, 'Transaction History'),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Text('No transactions yet.', style: TextStyle(color: Colors.grey));
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (c, i) {
                  final tx = TransactionModel.fromJson(
                      docs[i].data()! as Map<String, dynamic>);
                  return ListTile(
                    title: Text('${tx.orderType} – ${tx.deviceName}',
                        style: const TextStyle(color: Colors.black)),
                    subtitle: Text('Qty: ${tx.quantity}', style: const TextStyle(color: Colors.grey)),
                    trailing: Text(
                      '${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  );
                },
              );
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EcoByte Exchange', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: const Icon(Icons.savings, color: Colors.white), onPressed: _showCreateSIP)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTrending(),
            _buildCategoryChips(),
            _buildMarketSummary(),
            _buildStockChartSection(),
            _buildSIPSection(),
            _buildBuySell(),
            _buildTransactions(),
          ],
        ),
      ),
    );
  }
}
