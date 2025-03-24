import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint if needed

// Simple model for the e-waste center data we want to display
class EwasteCenter {
  final String name;
  final String address;
  final String? phoneNumber; // Might be null if not provided

  EwasteCenter({
    required this.name,
    required this.address,
    this.phoneNumber,
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
    debugPrint('Disposing controllers');
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _searchCenters() async {
    debugPrint('Search started');
    setState(() {
      _isLoading = true;
      _centers.clear();
    });

    // Log the user input values
    final addressText = _addressController.text;
    final pincodeText = _pincodeController.text;
    debugPrint('User input - Address: $addressText, Pincode: $pincodeText');

    final addressInput = '$addressText, $pincodeText';
    // Use your new unrestricted API key here
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    debugPrint('Using API key: $apiKey');

    try {
      // 1. Geocode the address -> lat/lng
      final geoUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?address=${Uri.encodeComponent(addressInput)}'
            '&key=$apiKey',
      );

      debugPrint('Geocode request URL: $geoUrl');

      final geoResponse = await http.get(geoUrl);
      final geoData = json.decode(geoResponse.body);
      debugPrint('Geocode response received: ${geoData.toString()}');

      if (geoData['status'] == 'OK' && geoData['results'].isNotEmpty) {
        final location = geoData['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        debugPrint('Parsed lat: $lat, lng: $lng');

        // 2. Use Places Nearby Search for "recycling center"
        final placesUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
              '?location=$lat,$lng'
              '&radius=50000'
              '&keyword=recycling+center'
              '&key=$apiKey',
        );

        debugPrint('Places request URL: $placesUrl');

        final nearbyResponse = await http.get(placesUrl);
        final nearbyData = json.decode(nearbyResponse.body);
        debugPrint('Nearby search response received: ${nearbyData.toString()}');

        if (nearbyData['status'] == 'OK' && nearbyData['results'] != null) {
          final results = nearbyData['results'] as List<dynamic>;
          List<EwasteCenter> centers = [];

          for (var place in results) {
            final placeId = place['place_id'];
            debugPrint('Processing place with ID: $placeId');

            // Fetch detailed info for each place
            final details = await _fetchPlaceDetails(placeId, apiKey);
            debugPrint('Details received for placeId $placeId: ${details.toString()}');

            // Use details when available, fallback to basic place info
            final name = details['name'] ?? place['name'] ?? 'Unknown Center';
            final address = details['formatted_address'] ??
                place['vicinity'] ??
                'No address available';
            final phoneNumber = details['formatted_phone_number'];

            debugPrint('Center - Name: $name, Address: $address, Phone: $phoneNumber');

            centers.add(EwasteCenter(
              name: name,
              address: address,
              phoneNumber: phoneNumber,
            ));
          }

          setState(() {
            _centers = centers;
          });
          debugPrint('Total centers found: ${centers.length}');
        } else {
          // No results or error from Places API
          debugPrint('Places search returned status: ${nearbyData['status']}');
          debugPrint('Places search error_message: ${nearbyData['error_message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No e-waste centers found nearby.')),
          );
        }
      } else {
        // Could not geocode the address
        debugPrint('Geocode returned status: ${geoData['status']}');
        debugPrint('Geocode error_message: ${geoData['error_message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to find location for given address.')),
        );
      }
    } catch (e) {
      debugPrint('Error caught in _searchCenters: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Search finished');
    }
  }

  // Helper to fetch place details for phone number, etc.
  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId, String? apiKey) async {
    debugPrint('Fetching details for placeId: $placeId');
    final detailsUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=name,formatted_address,formatted_phone_number'
          '&key=$apiKey',
    );

    debugPrint('Place details request URL: $detailsUrl');

    final detailsResponse = await http.get(detailsUrl);
    final detailsData = json.decode(detailsResponse.body);
    debugPrint('Place details response for $placeId: ${detailsData.toString()}');

    if (detailsData['status'] == 'OK') {
      return detailsData['result'] ?? {};
    } else {
      debugPrint('Details API returned status: ${detailsData['status']}');
      debugPrint('Details API error_message: ${detailsData['error_message']}');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building EwasteCentersPage widget');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find E-waste Centers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Address & Pincode inputs
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
              onPressed: _isLoading ? null : _searchCenters,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Search'),
            ),
            const SizedBox(height: 20),

            // Results list
            if (_centers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _centers.length,
                itemBuilder: (context, index) {
                  final center = _centers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(center.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(center.address),
                          if (center.phoneNumber != null)
                            Text('Phone: ${center.phoneNumber}'),
                        ],
                      ),
                    ),
                  );
                },
              )
            else if (!_isLoading)
            // If we have no centers and not loading, show a hint
              const Text('No results yet. Enter an address and pincode above.'),
          ],
        ),
      ),
    );
  }
}
