import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class TrackChipPage extends StatefulWidget {
  // E-waste center address from Firebase (point A)
  final String centerAddress;

  const TrackChipPage({Key? key, required this.centerAddress}) : super(key: key);

  @override
  _TrackChipPageState createState() => _TrackChipPageState();
}

class _TrackChipPageState extends State<TrackChipPage> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};

  // Fixed disintegration address (point B)
  final String disintegrationAddress = "Naidu Colony, Ghatkopar East, Mumbai, 400075";

  // List of manufacturer addresses (possible point C's)
  final List<String> manufacturerAddresses = [
    "ABC Recyclers, Mumbai, 400001",
    "XYZ E-Waste Solutions, Pune, 411001",
    "EcoFriendly Recycler, Delhi, 110001",
    "GreenChip Recyclers, Bengaluru, 560001",
    "ZeroWaste Co, Hyderabad, 500001"
  ];

  // State variables to save progress
  bool disposalRecorded = false;
  bool disintegrationRecorded = false;
  bool transferRecorded = false;

  // Stored LatLng for each step
  LatLng? centerLatLng;
  LatLng? disintegrationLatLng;
  LatLng? manufacturerLatLng;

  @override
  void initState() {
    super.initState();
    // First, get the coordinates for the center address (point A)
    _initializeCenterMarker();
  }

  Future<void> _initializeCenterMarker() async {
    try {
      List<Location> locations = await locationFromAddress(widget.centerAddress);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        centerLatLng = LatLng(loc.latitude, loc.longitude);
        _addOrUpdateMarker(MarkerId("center"), centerLatLng!, "E-Waste Center", widget.centerAddress);
        // Move camera to center
        _mapController?.animateCamera(CameraUpdate.newLatLng(centerLatLng!));
      }
    } catch (e) {
      print("Error fetching center address coordinates: $e");
    }
  }

  // Helper to add or update a marker
  void _addOrUpdateMarker(MarkerId markerId, LatLng position, String title, String snippet) {
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  // Helper to add a polyline arrow from one point to another
  void _addPolyline(String id, LatLng from, LatLng to) {
    final polyline = Polyline(
      polylineId: PolylineId(id),
      points: [from, to],
      color: Colors.green,
      width: 4,
      // Optionally add arrow styling if needed (Google Maps Flutter doesn't have built-in arrows)
    );
    setState(() {
      _polylines[PolylineId(id)] = polyline;
    });
  }

  // Simulate blockchain call to record disposal
  Future<void> _recordDisposal() async {
    // Simulate a blockchain call delay
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      disposalRecorded = true;
    });
    // At disposal, point A is already centerLatLng.
    // (You can also update additional on-chain data if needed.)
  }

  // Simulate blockchain call to record disintegration
  Future<void> _recordDisintegration() async {
    // Simulate blockchain call delay
    await Future.delayed(Duration(seconds: 2));
    try {
      List<Location> locations = await locationFromAddress(disintegrationAddress);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        disintegrationLatLng = LatLng(loc.latitude, loc.longitude);
        _addOrUpdateMarker(MarkerId("disintegration"), disintegrationLatLng!, "Disintegration Site", disintegrationAddress);
        if (centerLatLng != null) {
          _addPolyline("A-B", centerLatLng!, disintegrationLatLng!);
        }
        setState(() {
          disintegrationRecorded = true;
        });
      }
    } catch (e) {
      print("Error fetching disintegration address coordinates: $e");
    }
  }

  // Simulate blockchain call to record manufacturer transfer
  Future<void> _recordTransfer() async {
    // Simulate blockchain call delay
    await Future.delayed(Duration(seconds: 2));
    // Randomly pick a manufacturer address from the list
    final randomIndex = Random().nextInt(manufacturerAddresses.length);
    final selectedManufacturer = manufacturerAddresses[randomIndex];
    try {
      List<Location> locations = await locationFromAddress(selectedManufacturer);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        manufacturerLatLng = LatLng(loc.latitude, loc.longitude);
        _addOrUpdateMarker(MarkerId("manufacturer"), manufacturerLatLng!, "Manufacturer", selectedManufacturer);
        if (disintegrationLatLng != null) {
          _addPolyline("B-C", disintegrationLatLng!, manufacturerLatLng!);
        }
        setState(() {
          transferRecorded = true;
        });
      }
    } catch (e) {
      print("Error fetching manufacturer address coordinates: $e");
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Build buttons for each step if not yet recorded
  Widget _buildProgressButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Check Disposal Progress
        if (!disposalRecorded)
          ElevatedButton(
            onPressed: () async {
              await _recordDisposal();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Check Disposal Progress?"),
          )
        else
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Disposal recorded at center."),
          ),
        if (disposalRecorded)
          Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.green),
        // Check Disintegration Progress
        if (disposalRecorded && !disintegrationRecorded)
          ElevatedButton(
            onPressed: () async {
              await _recordDisintegration();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Check Disintegration Progress?"),
          )
        else if (disintegrationRecorded)
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Disintegration recorded at factory."),
          ),
        if (disintegrationRecorded)
          Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.green),
        // Check Manufacturer Details
        if (disintegrationRecorded && !transferRecorded)
          ElevatedButton(
            onPressed: () async {
              await _recordTransfer();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Check Manufacturer Details?"),
          )
        else if (transferRecorded)
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Transfer recorded at manufacturer."),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Chip"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Map container
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: centerLatLng ?? LatLng(19.0760, 72.8777),
                zoom: 12,
              ),
              markers: Set<Marker>.of(_markers.values),
              polylines: Set<Polyline>.of(_polylines.values),
              onMapCreated: (controller) {
                _mapController = controller;
                // If centerLatLng is already available, move camera to it.
                if (centerLatLng != null) {
                  _mapController!.animateCamera(CameraUpdate.newLatLng(centerLatLng!));
                }
              },
            ),
          ),
          SizedBox(height: 16),
          // Progress buttons & details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProgressButtons(),
          ),
        ],
      ),
    );
  }
}
