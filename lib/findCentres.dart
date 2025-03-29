import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

/// Model for E-Waste Drives from SERP API
class EwasteDrive {
  final String title;
  final String address;
  final String? mapLink;  // Google Maps link (either maps_url or fallback)
  final String? phone;  // phone number
  final String? website;  // website URL

  EwasteDrive({
    required this.title,
    required this.address,
    this.mapLink,
    this.phone,
    this.website,
  });
}

class FindCentresPage extends StatefulWidget {
  /// Suppose we pass the detected object name and its price from a previous screen.
  final String objectChosen;
  final double objectPrice;

  const FindCentresPage({
    Key? key,
    required this.objectChosen,
    required this.objectPrice,
  }) : super(key: key);

  @override
  State<FindCentresPage> createState() => _FindCentresPageState();
}

class _FindCentresPageState extends State<FindCentresPage> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  bool _isLoading = false;
  List<EwasteDrive> _drives = [];

  @override
  void dispose() {
    _areaController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _searchDrives() async {
    setState(() {
      _isLoading = true;
      _drives.clear();
    });

    final areaInput = _areaController.text;
    final pincodeInput = _pincodeController.text;
    final apiKey = dotenv.env['SERP_API_KEY'];

    // Combine area + pincode for a more precise query
    final query = 'e-waste drive near $areaInput $pincodeInput';
    final encodedQuery = Uri.encodeComponent(query);

    final serpUrl = Uri.parse(
      'https://serpapi.com/search.json?engine=google_maps&q=$encodedQuery&api_key=$apiKey',
    );

    try {
      final response = await http.get(serpUrl);
      final data = json.decode(response.body);

      if (data['local_results'] != null) {
        final results = data['local_results'] as List;
        List<EwasteDrive> drives = [];

        for (var result in results) {
          final title = result['title'] ?? 'Unknown Drive';
          final address = result['address'] ?? 'No address available';

          // If "maps_url" is present, use it, else fallback to custom link
          String mapUrl;
          if (result['maps_url'] != null && result['maps_url'].toString().isNotEmpty) {
            mapUrl = result['maps_url'];
          } else {
            mapUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
          }

          final phone = result['phone'];
          final website = result['website'];

          drives.add(
            EwasteDrive(
              title: title,
              address: address,
              mapLink: mapUrl,
              phone: phone,
              website: website,
            ),
          );
        }

        setState(() {
          _drives = drives;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No e-waste drives found in this area.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Method to confirm a drop-off location and store details in Firestore
  Future<void> _confirmDropOff(EwasteDrive drive) async {
    try {
      await FirebaseFirestore.instance.collection('scheduled_dropoff').add({
        'centerName': drive.title,
        'centerAddress': drive.address,
        'mapLink': drive.mapLink ?? '',
        'objectChosen': widget.objectChosen,
        'price': widget.objectPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending', // 👈 Add this field
      });


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drop-off location confirmed: ${drive.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving disposal: $e')),
      );
    }
  }

  Widget _buildDriveCard(EwasteDrive drive) {
    final cardColor = Colors.lightGreen[100]!;
    final buttonColor = Colors.green[800]!;
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                drive.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(drive.address),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Call
                  if (drive.phone != null)
                    IconButton(
                      icon: const Icon(Icons.call),
                      color: buttonColor,
                      onPressed: () async {
                        final uri = Uri(scheme: 'tel', path: drive.phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot launch phone dialer.')),
                          );
                        }
                      },
                    ),
                  // Website
                  if (drive.website != null)
                    IconButton(
                      icon: const Icon(Icons.language),
                      color: buttonColor,
                      onPressed: () async {
                        final uri = Uri.parse(drive.website!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot launch website.')),
                          );
                        }
                      },
                    ),
                  // Map
                  IconButton(
                    icon: const Icon(Icons.map),
                    color: buttonColor,
                    onPressed: () async {
                      final uri = Uri.parse(drive.mapLink ?? '');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot launch map.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // "Confirm as Drop off Location" button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                onPressed: () => _confirmDropOff(drive),
                child: const Text('Confirm as Drop off Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[400]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find E-Waste Facility"),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Area / Address input
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Enter Area/Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Pincode input
            TextField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Pincode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              onPressed: _isLoading ? null : _searchDrives,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Search Drives'),
            ),
            const SizedBox(height: 20),
            if (_drives.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _drives.length,
                itemBuilder: (context, index) {
                  final drive = _drives[index];
                  return _buildDriveCard(drive);
                },
              )
            else if (!_isLoading)
              const Text('No drives found.'),
          ],
        ),
      ),
    );
  }
}
