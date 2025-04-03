import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class TrackChipPage extends StatefulWidget {
  final String centerAddress; // E-waste Centre address from Firebase

  const TrackChipPage({Key? key, required this.centerAddress}) : super(key: key);

  @override
  _TrackChipPageState createState() => _TrackChipPageState();
}

class _TrackChipPageState extends State<TrackChipPage> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};

  // Hardcoded disintegration address
  final String disintegrationAddress = "Naidu Colony, Ghatkopar East, Mumbai, 400075";

  // Example manufacturer addresses
  final List<String> manufacturerAddresses = [
    "ABC Recyclers, Mumbai, 400001",
    "XYZ E-Waste Solutions, Pune, 411001",
    "EcoFriendly Recycler, Delhi, 110001",
    "GreenChip Recyclers, Bengaluru, 560001",
    "ZeroWaste Co, Hyderabad, 500001"
  ];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  Future<void> _initializeMarkers() async {
    // Marker 1: E-waste Centre (passed from Firebase)
    await _addMarker(widget.centerAddress, "E-Waste Centre", "E-waste disposed at centre");

    // Marker 2: Disintegration Site (hardcoded)
    await _addMarker(disintegrationAddress, "Disintegration Site", "Waste being disintegrated");

    // Marker 3: Manufacturer (random selection)
    final randomIndex = Random().nextInt(manufacturerAddresses.length);
    final selectedManufacturer = manufacturerAddresses[randomIndex];
    await _addMarker(selectedManufacturer, "Manufacturer", "Waste transferred for reuse");
  }

  // Geocode an address and add a marker on the map
  Future<void> _addMarker(String address, String title, String snippet) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final markerId = MarkerId(title);
        final marker = Marker(
          markerId: markerId,
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: InfoWindow(title: title, snippet: snippet),
        );
        setState(() {
          _markers[markerId] = marker;
        });
        // Optionally, move the camera to the last added marker:
        _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(loc.latitude, loc.longitude)));
      }
    } catch (e) {
      print("Error geocoding address '$address': $e");
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Chip"),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(19.0760, 72.8777), // Default to Mumbai
          zoom: 12,
        ),
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
