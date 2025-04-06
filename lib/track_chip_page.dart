import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import 'chip_tracker_contract.dart';
import 'blockchain_service.dart'; // optional if you have a dedicated service

class TrackChipPage extends StatefulWidget {
  final String centerAddress; // Disposal location
  const TrackChipPage({Key? key, required this.centerAddress}) : super(key: key);

  @override
  _TrackChipPageState createState() => _TrackChipPageState();
}

class _TrackChipPageState extends State<TrackChipPage> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};

  final String disintegrationAddress = "Naidu Colony, Ghatkopar East, Mumbai, 400075";

  final List<String> manufacturerAddresses = [
    "ABC Recyclers, Mumbai, 400001",
    "XYZ E-Waste Solutions, Pune, 411001",
    "EcoFriendly Recycler, Delhi, 110001",
    "GreenChip Recyclers, Bengaluru, 560001",
    "ZeroWaste Co, Hyderabad, 500001"
  ];

  // We'll store the entire flow in one UID
  String? chipUid;
  bool chipRegistered = false;
  bool disposalRecorded = false;
  bool disintegrationRecorded = false;
  bool transferRecorded = false;

  LatLng? centerLatLng;
  LatLng? disintegrationLatLng;
  LatLng? manufacturerLatLng;

  // Blockchain
  late BlockchainService blockchainService;   // If you prefer a direct Web3Client, that's fine too
  late ChipTrackerContract chipTracker;
  late Credentials credentials;
  late EthereumAddress myAddress;

  @override
  void initState() {
    super.initState();
    _initBlockchain();
    _loadProgress();
  }

  // 1) Initialize blockchain objects
  Future<void> _initBlockchain() async {
    blockchainService = BlockchainService();

    final privateKey = dotenv.env['PRIVATE_KEY']!;
    credentials = EthPrivateKey.fromHex(privateKey);
    myAddress = await credentials.extractAddress();

    final contractAddr = EthereumAddress.fromHex(dotenv.env['CONTRACT_ADDRESS']!);
    chipTracker = await ChipTrackerContract.load(
      blockchainService.client,
      contractAddr,
    );
  }

  // 2) Load or create UID + progress
  Future<void> _loadProgress() async {
    final sp = await SharedPreferences.getInstance();

    // Attempt to restore previously generated UID
    chipUid = sp.getString('chipUid');
    chipRegistered = sp.getBool('chipRegistered') ?? false;
    disposalRecorded = sp.getBool('disposalRecorded') ?? false;
    disintegrationRecorded = sp.getBool('disintegrationRecorded') ?? false;
    transferRecorded = sp.getBool('transferRecorded') ?? false;

    // If no stored UID, create a new random one and store it
    if (chipUid == null) {
      final randUid = "chip${Random().nextInt(9999999)}";
      chipUid = randUid;
      await sp.setString('chipUid', randUid);

      // Now register it on chain so "Chip not registered" won't happen
      await _registerChip(chipUid!);
    }

    // Restore existing markers
    if (disposalRecorded) await _initializeCenterMarker();
    if (disintegrationRecorded) await _recordDisintegrationMarkerOnly();
    if (transferRecorded) await _recordTransferMarkerOnly();

    setState(() {});
  }

  Future<void> _registerChip(String uid) async {
    final manufactureDate = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await chipTracker.registerChip(uid, manufactureDate, credentials);

    // Mark in SharedPreferences
    final sp = await SharedPreferences.getInstance();
    sp.setBool('chipRegistered', true);
    chipRegistered = true;
  }

  // 3) Save progress
  Future<void> _saveProgress() async {
    final sp = await SharedPreferences.getInstance();
    sp.setBool('chipRegistered', chipRegistered);
    sp.setBool('disposalRecorded', disposalRecorded);
    sp.setBool('disintegrationRecorded', disintegrationRecorded);
    sp.setBool('transferRecorded', transferRecorded);
  }

  // 4) Disposal
  Future<void> _recordDisposal() async {
    if (!chipRegistered || chipUid == null) return;

    // Mark the chip disposal location on map
    await _initializeCenterMarker();

    // On-chain
    final timestamp = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await chipTracker.recordDisposal(chipUid!, timestamp, widget.centerAddress, credentials);

    disposalRecorded = true;
    await _saveProgress();
    setState(() {});
  }

  // 5) Disintegration
  Future<void> _recordDisintegration() async {
    if (chipUid == null || !disposalRecorded) return;

    final locs = await locationFromAddress(disintegrationAddress);
    if (locs.isEmpty) return;

    final loc = locs.first;
    disintegrationLatLng = LatLng(loc.latitude, loc.longitude);
    _addOrUpdateMarker(MarkerId("disintegration"), disintegrationLatLng!, "Disintegration Site", disintegrationAddress);

    if (centerLatLng != null) {
      _addPolyline("A-B", centerLatLng!, disintegrationLatLng!);
    }

    // On-chain
    final timestamp = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await chipTracker.recordDisintegration(chipUid!, timestamp, disintegrationAddress, credentials);

    disintegrationRecorded = true;
    await _saveProgress();
    setState(() {});
  }

  // 6) Transfer
  Future<void> _recordTransfer() async {
    if (chipUid == null || !disintegrationRecorded) return;

    final selected = manufacturerAddresses[Random().nextInt(manufacturerAddresses.length)];
    final locs = await locationFromAddress(selected);
    if (locs.isEmpty) return;

    final loc = locs.first;
    manufacturerLatLng = LatLng(loc.latitude, loc.longitude);
    _addOrUpdateMarker(MarkerId("manufacturer"), manufacturerLatLng!, "Manufacturer", selected);

    if (disintegrationLatLng != null) {
      _addPolyline("B-C", disintegrationLatLng!, manufacturerLatLng!);
    }

    // On-chain
    final timestamp = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await chipTracker.recordTransferForReuse(chipUid!, timestamp, myAddress, selected, credentials);

    transferRecorded = true;
    await _saveProgress();
    setState(() {});
  }

  // Marker-only for disintegration if returning to the page
  Future<void> _recordDisintegrationMarkerOnly() async {
    final locs = await locationFromAddress(disintegrationAddress);
    if (locs.isNotEmpty) {
      final loc = locs.first;
      disintegrationLatLng = LatLng(loc.latitude, loc.longitude);
      _addOrUpdateMarker(MarkerId("disintegration"), disintegrationLatLng!, "Disintegration Site", disintegrationAddress);

      if (centerLatLng != null) {
        _addPolyline("A-B", centerLatLng!, disintegrationLatLng!);
      }
    }
  }

  // Marker-only for transfer
  Future<void> _recordTransferMarkerOnly() async {
    final selected = manufacturerAddresses[0];
    final locs = await locationFromAddress(selected);
    if (locs.isNotEmpty) {
      final loc = locs.first;
      manufacturerLatLng = LatLng(loc.latitude, loc.longitude);
      _addOrUpdateMarker(MarkerId("manufacturer"), manufacturerLatLng!, "Manufacturer", selected);

      if (disintegrationLatLng != null) {
        _addPolyline("B-C", disintegrationLatLng!, manufacturerLatLng!);
      }
    }
  }

  // Marker for disposal center
  Future<void> _initializeCenterMarker() async {
    final locs = await locationFromAddress(widget.centerAddress);
    if (locs.isNotEmpty) {
      final loc = locs.first;
      centerLatLng = LatLng(loc.latitude, loc.longitude);
      _addOrUpdateMarker(MarkerId("center"), centerLatLng!, "E-Waste Center", widget.centerAddress);
      _mapController?.animateCamera(CameraUpdate.newLatLng(centerLatLng!));
    }
  }

  // Marker + Polyline helpers
  void _addOrUpdateMarker(MarkerId markerId, LatLng pos, String title, String snippet) {
    final marker = Marker(markerId: markerId, position: pos, infoWindow: InfoWindow(title: title, snippet: snippet));
    setState(() {
      _markers[markerId] = marker;
    });
  }

  void _addPolyline(String id, LatLng from, LatLng to) {
    final polyline = Polyline(
      polylineId: PolylineId(id),
      points: [from, to],
      color: Colors.green,
      width: 4,
    );
    setState(() {
      _polylines[PolylineId(id)] = polyline;
    });
  }

  // Buttons that handle each step
  Widget _buildProgressButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!disposalRecorded)
          ElevatedButton(
            onPressed: _recordDisposal,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Check Disposal Progress?"),
          )
        else
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Disposal recorded at center."),
          ),

        if (disposalRecorded)
          const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.green),

        if (disposalRecorded && !disintegrationRecorded)
          ElevatedButton(
            onPressed: _recordDisintegration,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Check Disintegration Progress?"),
          )
        else if (disintegrationRecorded)
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Disintegration recorded at factory."),
          ),

        if (disintegrationRecorded)
          const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.green),

        if (disintegrationRecorded && !transferRecorded)
          ElevatedButton(
            onPressed: _recordTransfer,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Check Manufacturer Details?"),
          )
        else if (transferRecorded)
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Transfer recorded at manufacturer."),
          ),
      ],
    );
  }

  @override
  void dispose() {
    blockchainService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Chip"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: centerLatLng ?? const LatLng(19.0760, 72.8777),
                zoom: 12,
              ),
              markers: _markers.values.toSet(),
              polylines: _polylines.values.toSet(),
              onMapCreated: (controller) {
                _mapController = controller;
                if (centerLatLng != null) {
                  _mapController!.animateCamera(CameraUpdate.newLatLng(centerLatLng!));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProgressButtons(),
          ),
        ],
      ),
    );
  }
}
