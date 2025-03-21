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
              // Get the country name based on location (reverse geocoding)
              String country = await getCountryFromCoordinates(location);
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
    try {
      // Send the country name to OpenAI API
      final eWastePerCapita = await getEWasteDataFromOpenAI(country);

      setState(() {
        _eWasteData = 'E-waste generated for $country: $eWastePerCapita';
      });
    } catch (e) {
      setState(() {
        _eWasteData = 'Error fetching e-waste data: $e';
      });
    }
  }

  // Fetch data from OpenAI API
  Future<String> getEWasteDataFromOpenAI(String country) async {
    final openAiApiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/completions');

    final headers = {
      'Authorization': 'Bearer $openAiApiKey',
      'Content-Type': 'application/json',
    };

    final prompt = '''
    I have the following information for a country: 
    Country: $country

    Please retrieve the e-waste generated data for $country from the website: https://globalewaste.org/statistics/country/$country/2022/
    Extract only the "e-waste generated per capita" value and return it.
    ''';

    final body = json.encode({
      'model': 'text-davinci-003',
      'prompt': prompt,
      'max_tokens': 150,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['text'].toString().trim();
    } else {
      throw Exception('Failed to get data from OpenAI');
    }
  }

  // Reverse geocode: Get the country name based on coordinates (latitude, longitude)
  Future<String> getCountryFromCoordinates(LatLng location) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']; // Your Google Maps Geocoding API Key
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
              return component['long_name'];
            }
          }

      }
      return 'Country not found';
    } else {
      throw Exception('Failed to get country from coordinates');
    }
  }
}
