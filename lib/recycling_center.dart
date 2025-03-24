import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:url_launcher/url_launcher.dart'; // to launch URLs

// Updated model for the e-waste center data, including website and map link.
class EwasteCenter {
  final String name;
  final String address;
  final String? phoneNumber; // May be null.
  final String? website;     // Website URL (if available).
  final String? mapLink;     // Map URL from SERP API (if available).

  EwasteCenter({
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
    this.mapLink,
  });
}

class EwasteCentersPage extends StatefulWidget {
  const EwasteCentersPage({Key? key}) : super(key: key);

  @override
  State<EwasteCentersPage> createState() => _EwasteCentersPageState();
}

class _EwasteCentersPageState extends State<EwasteCentersPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  bool _isLoading = false;
  List<EwasteCenter> _centers = [];

  @override
  void dispose() {
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Updated cleaning function: preserves '+' at the beginning, removes spaces, dashes, and parentheses.
  String _cleanPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      return '+' + phone.substring(1).replaceAll(RegExp(r'[\s\-\(\)]'), '');
    } else {
      return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    }
  }

  // If the SERP API does not provide a valid map link, generate a fallback URL using the address.
  String _getMapUrl(EwasteCenter center) {
    if (center.mapLink != null && center.mapLink!.isNotEmpty) {
      return center.mapLink!;
    } else {
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(center.address)}';
    }
  }

  Future<void> _searchCenters() async {
    setState(() {
      _isLoading = true;
      _centers.clear();
    });

    final addressInput = '${_addressController.text}, ${_pincodeController.text}';
    // Retrieve your SERP API key from your .env file.
    final apiKey = dotenv.env['SERP_API_KEY'];

    // Update query to focus on e-waste recycling/disposal centers.
    final query = 'e-waste recycling center near $addressInput';
    final encodedQuery = Uri.encodeComponent(query);

    // Construct the SERP API URL for Google Maps results.
    final serpUrl = Uri.parse(
      'https://serpapi.com/search.json?engine=google_maps&q=$encodedQuery&api_key=$apiKey',
    );

    debugPrint('SERP API request URL: $serpUrl');

    try {
      final response = await http.get(serpUrl);
      final data = json.decode(response.body);

      // Log entire SERP API response.
      debugPrint('SERP API response: ${data.toString()}');

      if (data['local_results'] != null) {
        final results = data['local_results'] as List;
        List<EwasteCenter> centers = [];
        for (var result in results) {
          final name = result['title'] ?? 'Unknown Center';
          final address = result['address'] ?? 'No address available';
          final phone = result['phone']; // May be null.

          // Try to extract a website link; if not, fallback to "link".
          final website = (result['website'] != null && result['website'].toString().isNotEmpty)
              ? result['website']
              : (result['link'] != null && result['link'].toString().isNotEmpty ? result['link'] : null);

          // Extract the map link from "maps_url", if available.
          final mapLink = (result['maps_url'] != null && result['maps_url'].toString().isNotEmpty)
              ? result['maps_url']
              : null;

          centers.add(EwasteCenter(
            name: name,
            address: address,
            phoneNumber: phone,
            website: website,
            mapLink: mapLink,
          ));
        }
        setState(() {
          _centers = centers;
        });
      } else {
        debugPrint('No local_results found in SERP API response.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No e-waste centers found nearby.')),
        );
      }
    } catch (e) {
      debugPrint('Error during SERP API request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to launch a URL for websites, maps, or phone dialer.
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Updated color scheme.
    final cardColor = Colors.lightGreen[300];  // A gentle light green.
    final buttonColor = Colors.lightGreen[800];       // A darker, richer green for icons and text.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find E-waste Centers'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input fields for address and pincode.
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
              ),
              onPressed: _isLoading ? null : _searchCenters,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Search'),
            ),
            const SizedBox(height: 20),
            // Display results.
            if (_centers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _centers.length,
                itemBuilder: (context, index) {
                  final center = _centers[index];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        center.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(center.address),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (center.phoneNumber != null && center.phoneNumber!.isNotEmpty)
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: buttonColor,
                                  ),
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Call'),
                                  onPressed: () {
                                    final cleanNumber = _cleanPhoneNumber(center.phoneNumber!);
                                    debugPrint('Launching phone dialer for: tel:$cleanNumber');
                                    _launchURL('tel:$cleanNumber');
                                  },
                                ),
                              if (center.website != null && center.website!.isNotEmpty)
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: buttonColor,
                                  ),
                                  icon: const Icon(Icons.language),
                                  label: const Text('Website'),
                                  onPressed: () => _launchURL(center.website!),
                                ),
                              // Always show Map button using fallback if needed.
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: buttonColor,
                                ),
                                icon: const Icon(Icons.map),
                                label: const Text('Map'),
                                onPressed: () => _launchURL(_getMapUrl(center)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else if (!_isLoading)
              const Text('No results yet. Enter an address and pincode above.'),
          ],
        ),
      ),
    );
  }
}
