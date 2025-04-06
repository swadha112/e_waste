import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'edrives.dart';
import 'findCentres.dart';

import 'how_u_help.dart'; // Your final target page

class CenterSelectionPage extends StatefulWidget {
  final PickupRequest request;         // Your data model
  final String pickupRequestId;

  const CenterSelectionPage({
    super.key,
    required this.request,
    required this.pickupRequestId,
  });

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
      'https://serpapi.com/search.json?engine=google_maps&q=${Uri.encodeComponent(query)}&api_key=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      final results = data['local_results'] ?? [];
      setState(() {
        _centers = (results as List).map<EwasteDrive>((center) {
          return EwasteDrive(
            title: center['title'] ?? 'Unknown Center',
            address: center['address'] ?? 'No address available',
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching centers: $e");
      setState(() => _isLoading = false);
    }
  }

  // Minimal update: as soon as user taps "Schedule Pickup", just:
  //  1) Save center in Firestore
  //  2) Send message if you want
  //  3) Show success + redirect to HowCanYouHelpPage
  Future<void> _sendPickupMessage(EwasteDrive center) async {
    try {
      // 1) Save center in Firestore
      await FirebaseFirestore.instance
          .collection('pickup_requests')
          .doc(widget.pickupRequestId)
          .update({
        'selectedCenterName': center.title,
        'selectedCenterAddress': center.address,
      });

      // 2) (Optional) Send a WhatsApp message via your cloud function
      final url = Uri.parse(
        "https://us-central1-e-waste-453420.cloudfunctions.net/sendWhatsAppMessage",
      );
      final messageBody = '''
📦 E-Waste Pickup Scheduled
Name: ${widget.request.name}
Contact: ${widget.request.contact}
Location: ${widget.request.flatNo}, ${widget.request.buildingName}, ${widget.request.locality}, ${widget.request.city}
Date: ${widget.request.scheduledDateTime.toIso8601String()}
Center: ${center.title}

Thank you for scheduling your pickup!
''';

      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'messageBody': messageBody,
          'sessionId': sessionId,
          'userContact': 'whatsapp:${widget.request.contact}',
          'documentId': widget.pickupRequestId,
          'collectionName': 'pickup_requests',
        }),
      );
      debugPrint("WhatsApp response: ${response.statusCode} => ${response.body}");

      // 3) Immediately show success and redirect
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Pickup Scheduled Successfully!"),
          content: Text("Center: ${center.title}\n\nWe’ll be in touch soon."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HowCanYouHelpPage()),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
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
