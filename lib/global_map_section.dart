import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GlobalMapSection extends StatefulWidget {
  final Set<Marker> markers;

  const GlobalMapSection({Key? key, required this.markers}) : super(key: key);

  @override
  _GlobalMapSectionState createState() => _GlobalMapSectionState();
}

class _GlobalMapSectionState extends State<GlobalMapSection> {
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.0, 0.0),
    zoom: 2,
  );

  late GoogleMapController _mapController;
  String _eWasteData = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: widget.markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng location) async {
              print("Map tapped at: Lat: ${location.latitude}, Lng: ${location.longitude}");
              // Get the country name based on location (reverse geocoding)
              String country = await getCountryFromCoordinates(location);
              print("Country found: $country");
              _fetchEWasteData(country);
            },
          ),
        ),
        if (_eWasteData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _eWasteData,
              style: TextStyle(fontSize: 18),
            ),
          ),
      ],
    );
  }

  // Fetch e-waste per capita data for the clicked country
  Future<void> _fetchEWasteData(String country) async {
    print("Fetching e-waste data for $country...");
    try {
      // Send the country name to Google Custom Search API
      final eWastePerCapita = await getEWasteDataFromGoogleSearch(country);
      print("E-waste data fetched: $eWastePerCapita");

      setState(() {
        _eWasteData = 'E-waste generated for $country: $eWastePerCapita';
      });
    } catch (e) {
      print("Error fetching e-waste data: $e");
      setState(() {
        _eWasteData = 'Error fetching e-waste data: $e';
      });
    }
  }

  // Fetch data from Google Custom Search API
  Future<String> getEWasteDataFromGoogleSearch(String country) async {
    print("Sending request to Google Custom Search API for country: $country");

    final apiKey = dotenv.env['GOOGLE_CSE_API_KEY']; // Your Google API key
    final cseId = dotenv.env['GOOGLE_CSE_CX']; // Your Custom Search Engine ID
    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?q=e-waste+generated+per+capita+$country&key=$apiKey&cx=$cseId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Process the search result and extract the required information
      if (data['items'] != null && data['items'].isNotEmpty) {
        for (var item in data['items']) {
          // Search through the items to find relevant information (adjust based on actual data structure)
          final snippet = item['snippet'] ?? '';
          if (snippet.contains('e-waste generated per capita')) {
            print("Found e-waste data: $snippet");
            return snippet; // Return the relevant snippet or data
          }
        }
      }
      return 'No relevant data found';
    } else {
      print("Failed to get data from Google Custom Search: ${response.statusCode}");
      throw Exception('Failed to get data from Google Custom Search');
    }
  }

  // Reverse geocode: Get the country name based on coordinates (latitude, longitude)
  Future<String> getCountryFromCoordinates(LatLng location) async {
    print("Reverse geocoding location: Lat: ${location.latitude}, Lng: ${location.longitude}");

    final apiKey =dotenv.env['GOOGLE_MAPS_API_KEY']; // Your Google Maps Geocoding API Key
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        // Loop through the results to find the country
        for (var result in data['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('country')) {
              print("Found country: ${component['long_name']}");
              return component['long_name'];
            }
          }
        }
      }
      print("Country not found in reverse geocoding results.");
      return 'Country not found';
    } else {
      print("Error during reverse geocoding: ${response.statusCode}");
      throw Exception('Failed to get country from coordinates');
    }
  }
}
