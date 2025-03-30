// ============================
// Flutter: CenterSelectionPage.dart
// ============================
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'edrives.dart';
import 'findCentres.dart';

class CenterSelectionPage extends StatefulWidget {
  final PickupRequest request;
  final String pickupRequestId;
  const CenterSelectionPage({super.key, required this.request, required this.pickupRequestId,});

  @override
  State<CenterSelectionPage> createState() => _CenterSelectionPageState();
}

class _CenterSelectionPageState extends State<CenterSelectionPage> {
  List<EwasteDrive> _centers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbyCenters();
  }

  Future<void> _fetchNearbyCenters() async {
    final query =
        'e-waste collection center near ${widget.request.locality}, ${widget.request.city}';
    final apiKey = dotenv.env['SERP_API_KEY'];
    final url = Uri.parse(
        'https://serpapi.com/search.json?engine=google_maps&q=${Uri.encodeComponent(query)}&api_key=$apiKey');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      final results = data['local_results'] ?? [];
      setState(() {
        _centers = (results as List).map<EwasteDrive>((center) {
          return EwasteDrive(
            title: center['title'] ?? 'Unknown Center',
            address: center['address'] ?? 'No address available',
            //detailsLink: center['maps_url'],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching centers: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPickupMessage(EwasteDrive center) async {
    final url = Uri.parse(
        "https://us-central1-e-waste-453420.cloudfunctions.net/sendWhatsAppMessage");
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final messageBody = '''
📦 E-Waste Pickup Scheduled
Name: ${widget.request.name}
Contact: ${widget.request.contact}
Location: ${widget.request.flatNo}, ${widget.request.buildingName}, ${widget.request.locality}, ${widget.request.city}
Date: ${widget.request.scheduledDateTime.toIso8601String()}
Center: ${center.title}

Are you available for pickup?
Reply:
1️⃣ Yes, successful pickup
2️⃣ No, not available
''';
    print("📤 Sending POST to $url");
    print("📦 Payload: $messageBody");

    print("✅ Sending with:");
    print("messageBody: $messageBody");
    print("userContact: whatsapp:${widget.request.contact}");
    print("sessionId: $sessionId");
    print("pickupReqId: $widget.pickupRequestId");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'messageBody': messageBody,
        'sessionId': sessionId,
        'userContact': 'whatsapp:${widget.request.contact}',
        'pickupRequestId': widget.pickupRequestId,
      }),
    );

    print("📬 Response Code: ${response.statusCode}");
    print("📬 Response Body: ${response.body}");

    if (response.statusCode == 201) {
      _listenToConfirmation(sessionId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.body}')),
      );
    }
  }

  void _listenToConfirmation(String sessionId) async {
    print("👂 Listening to session: $sessionId");
    final docRef = FirebaseFirestore.instance.collection('sessions').doc(sessionId);
    docRef.snapshots().listen((doc) {
      print("📡 Firestore snapshot received: exists = ${doc.exists}");
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;
      print("📄 Firestore data: $data");
      if (data['replied'] == true) {
        if (data['confirmed'] == true) {
          print("✅ Pickup confirmed by center.");
          _calculateCarbonAndReward();
        } else {
          print("❌ Pickup rejected by center.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pickup not confirmed.")),
          );
        }
      }
    });
  }

  void _calculateCarbonAndReward() {
    final typeWeight = 5;
    final carbonSaved = typeWeight * 0.8;
    final updatedPoints = widget.request.rewardPoints + 50;

    FirebaseFirestore.instance.collection('rewards').add({
      'user': widget.request.contact,
      'carbonSaved': carbonSaved,
      'rewardPoints': updatedPoints,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (updatedPoints >= 250) {
      _showCouponPopup(updatedPoints);
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pickup Successful 🎉"),
        content:
        Text("You saved \$carbonSaved kg of CO₂!\n+50 reward points added."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  void _showCouponPopup(int points) {
    final coupon = "GREENFUTURE250";

    FirebaseFirestore.instance.collection('coupons').add({
      'user': widget.request.contact,
      'points': points,
      'code': coupon,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You Earned a Coupon! 🎁"),
        content:
        Text("Use code **\$coupon** on your next e-waste recycling order."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Sweet!")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select E-Waste Center")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _centers.length,
        itemBuilder: (context, index) {
          final center = _centers[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(center.title),
              subtitle: Text(center.address),
              trailing: ElevatedButton(
                child: const Text("Schedule Pickup"),
                onPressed: () => _sendPickupMessage(center),
              ),
            ),
          );
        },
      ),
    );
  }
}
