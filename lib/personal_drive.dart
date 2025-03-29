import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Simple model for an e-waste center returned by SerpAPI.
class EwasteDrive {
  final String title;
  final String address;

  EwasteDrive({
    required this.title,
    required this.address,
  });
}

/// Model for Personal Pickup Request data
class PersonalPickupRequest {
  final String name;
  final String flatNo;
  final String streetAddress;
  final String locality;
  final String city;
  final String state;
  final String contact;
  final DateTime scheduledDateTime;
  final String deviceName;
  final double devicePrice;

  /// Optionally store status, rewardPoints, etc.
  final String status;
  final int rewardPoints;

  PersonalPickupRequest({
    required this.name,
    required this.flatNo,
    required this.streetAddress,
    required this.locality,
    required this.city,
    required this.state,
    required this.contact,
    required this.scheduledDateTime,
    required this.deviceName,
    required this.devicePrice,
    this.status = 'Pending',
    this.rewardPoints = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'flatNo': flatNo,
      'streetAddress': streetAddress,
      'locality': locality,
      'city': city,
      'state': state,
      'contact': contact,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'deviceName': deviceName,
      'devicePrice': devicePrice,
      'status': status,
      'rewardPoints': rewardPoints,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class PersonalDrivePage extends StatefulWidget {
  final String objectChosen;
  final double objectPrice;

  const PersonalDrivePage({
    Key? key,
    required this.objectChosen,
    required this.objectPrice,
  }) : super(key: key);

  @override
  State<PersonalDrivePage> createState() => _PersonalDrivePageState();
}

class _PersonalDrivePageState extends State<PersonalDrivePage> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isFetchingCenters = false;
  List<EwasteDrive> _centers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _streetController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Pick date & time
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// 1) Validate form & date
  /// 2) Build PersonalPickupRequest
  /// 3) Fetch centers from SerpAPI
  Future<void> _fetchNearbyCenters() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a date/time'),
        ),
      );
      return;
    }

    setState(() => _isFetchingCenters = true);

    // Create the request object
    final request = PersonalPickupRequest(
      name: _nameController.text,
      flatNo: _flatController.text,
      streetAddress: _streetController.text,
      locality: _localityController.text,
      city: _cityController.text,
      state: _stateController.text,
      contact: _contactController.text,
      scheduledDateTime: _selectedDateTime!,
      deviceName: widget.objectChosen,
      devicePrice: widget.objectPrice,
    );

    // Optionally store the request in Firestore (if you want to keep a record).
    // If you only want to store it AFTER user selects a center, you can do that
    // inside _sendPickupMessage() instead. For example:
    // await FirebaseFirestore.instance.collection('Scheduled_pickup').add(request.toMap());

    // Build query from user input
    final query =
        'e-waste collection center near ${request.locality}, ${request.city}';
    final apiKey = dotenv.env['SERP_API_KEY'] ?? '';
    final url = Uri.parse(
      'https://serpapi.com/search.json?engine=google_maps&q=${Uri.encodeComponent(query)}&api_key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['local_results'] ?? [];
        final centers = (results as List).map<EwasteDrive>((center) {
          return EwasteDrive(
            title: center['title'] ?? 'Unknown Center',
            address: center['address'] ?? 'No address available',
          );
        }).toList();

        setState(() {
          _centers = centers;
        });
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching centers: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("Exception while fetching centers: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isFetchingCenters = false);
    }
  }

  /// Send a WhatsApp message to the user (or center) to confirm pickup
  /// Here we show how to incorporate your “sendWhatsAppMessage” flow
  Future<void> _sendPickupMessage(EwasteDrive center) async {
    // Build the personal request again from the form
    final request = PersonalPickupRequest(
      name: _nameController.text,
      flatNo: _flatController.text,
      streetAddress: _streetController.text,
      locality: _localityController.text,
      city: _cityController.text,
      state: _stateController.text,
      contact: _contactController.text,
      scheduledDateTime: _selectedDateTime!,
      deviceName: widget.objectChosen,
      devicePrice: widget.objectPrice,
    );

    // Store in Firestore with chosen center
    // Optionally store 'centerTitle' and 'centerAddress' in the doc
    final docRef = await FirebaseFirestore.instance
        .collection('Scheduled_pickup')
        .add({
      ...request.toMap(),
      'centerTitle': center.title,
      'centerAddress': center.address,
    });

    final sessionId = docRef.id; // or any unique ID
    final messageBody = '''
📦 E-Waste Pickup Scheduled
Name: ${request.name}
Contact: ${request.contact}
Location: ${request.flatNo}, ${request.streetAddress}, ${request.locality}, ${request.city}, ${request.state}
Date: ${request.scheduledDateTime.toIso8601String()}
Center: ${center.title}

Are you available for pickup?
Reply:
1️⃣ Yes, successful pickup
2️⃣ No, not available
''';

    final functionUrl =
        "https://us-central1-e-waste-453420.cloudfunctions.net/sendWhatsAppMessage";
    debugPrint("Sending WhatsApp message to $functionUrl");
    debugPrint("Payload: $messageBody");

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'messageBody': messageBody,
          'sessionId': sessionId,
          'userContact': 'whatsapp:${request.contact}',
        }),
      );

      if (response.statusCode == 201) {
        // Start listening for the user's confirmation in Firestore
        _listenToConfirmation(sessionId, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup request sent via WhatsApp!')),
        );
      } else {
        debugPrint("Failed to send message: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp send failed: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("Error sending WhatsApp message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending WhatsApp message: $e')),
      );
    }
  }

  /// Listen for Firestore doc updates (like user replying with "Yes" or "No")
  void _listenToConfirmation(String sessionId, PersonalPickupRequest request) {
    final docRef = FirebaseFirestore.instance.collection('sessions').doc(sessionId);
    docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;
      if (data['replied'] == true) {
        if (data['confirmed'] == true) {
          debugPrint("✅ Pickup confirmed by user/center.");
          _calculateCarbonAndReward(request);
        } else {
          debugPrint("❌ Pickup rejected.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pickup not confirmed.")),
          );
        }
      }
    });
  }

  /// Example: calculate carbon saved or reward points
  void _calculateCarbonAndReward(PersonalPickupRequest request) {
    // Suppose each device has a weight of 2 kg => 0.8 kg CO2 saved per kg, etc.
    final double deviceWeight = 2.0; // Example
    final double carbonSaved = deviceWeight * 0.8;
    final int updatedPoints = request.rewardPoints + 50;

    // Store results in Firestore (optional)
    FirebaseFirestore.instance.collection('rewards').add({
      'user': request.contact,
      'carbonSaved': carbonSaved,
      'rewardPoints': updatedPoints,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Check if user is eligible for coupon
    if (updatedPoints >= 250) {
      _showCouponPopup(updatedPoints, request.contact);
    }

    // Show a success message
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pickup Successful 🎉"),
        content: Text(
          "You saved $carbonSaved kg of CO₂!\n+50 reward points added.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Show coupon popup if points threshold reached
  void _showCouponPopup(int points, String userContact) {
    final coupon = "GREENFUTURE250";

    FirebaseFirestore.instance.collection('coupons').add({
      'user': userContact,
      'points': points,
      'code': coupon,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You Earned a Coupon! 🎁"),
        content: Text("Use code $coupon on your next e-waste recycling order."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Sweet!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[800];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal E-Waste Pickup"),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// =========== FORM ===============
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 8),
                  // Flat
                  TextFormField(
                    controller: _flatController,
                    decoration: const InputDecoration(labelText: 'Flat No'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter flat number'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  // Street
                  TextFormField(
                    controller: _streetController,
                    decoration:
                    const InputDecoration(labelText: 'Street Address'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter street address'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  // Locality
                  TextFormField(
                    controller: _localityController,
                    decoration:
                    const InputDecoration(labelText: 'Locality/Area'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter locality'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  // City
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Enter city' : null,
                  ),
                  const SizedBox(height: 8),
                  // State
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Enter state' : null,
                  ),
                  const SizedBox(height: 8),
                  // Contact
                  TextFormField(
                    controller: _contactController,
                    decoration:
                    const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter contact number'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? 'No date/time selected'
                              : 'Selected: ${_selectedDateTime!.toLocal().toString().substring(0, 16)}',
                        ),
                      ),
                      ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(backgroundColor: buttonColor),
                        onPressed: _pickDateTime,
                        child: const Text('Pick Date & Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// =========== BUTTON: FIND CENTERS ===============
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              onPressed: _isFetchingCenters ? null : _fetchNearbyCenters,
              child: _isFetchingCenters
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Find Nearby Centers'),
            ),

            const SizedBox(height: 24),

            /// =========== DISPLAY CENTERS ===============
            if (_centers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _centers.length,
                itemBuilder: (context, index) {
                  final center = _centers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(center.title),
                      subtitle: Text(center.address),
                      trailing: ElevatedButton(
                        onPressed: () => _sendPickupMessage(center),
                        child: const Text("Confirm Pickup"),
                      ),
                    ),
                  );
                },
              )
            else if (!_isFetchingCenters)
              const Text(
                "No centers found. Please fill the form and tap 'Find Nearby Centers'.",
              ),
          ],
        ),
      ),
    );
  }
}
