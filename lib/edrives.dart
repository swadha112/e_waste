import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // For clipboard
import 'package:lottie/lottie.dart'; // For Lottie animations
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'centerSelection.dart'; // adjust path as needed


// --- Model for E-Waste Drives from SERP API ---
class EwasteDrive {
  final String title;
  final String address;
  final String? detailsLink; // e.g. maps URL or website if available

  EwasteDrive({
    required this.title,
    required this.address,
    this.detailsLink,
  });
}

// --- Model for Pickup Request Form Data ---
class PickupRequest {
  final String name;
  final String flatNo;
  final String buildingName;
  final String streetAddress;
  final String locality;
  final String city;
  final String state;
  final String contact;
  final DateTime scheduledDateTime;
  final String frequency;
  final int approxPeople;
  final String pickupFor; // "Self", "Building", "Locality"
  final String couponCode;
  final int rewardPoints;

  PickupRequest({
    required this.name,
    required this.flatNo,
    required this.buildingName,
    required this.streetAddress,
    required this.locality,
    required this.city,
    required this.state,
    required this.contact,
    required this.scheduledDateTime,
    required this.frequency,
    required this.approxPeople,
    required this.pickupFor,
    required this.couponCode,
    required this.rewardPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'flatNo': flatNo,
      'buildingName': buildingName,
      'streetAddress': streetAddress,
      'locality': locality,
      'city': city,
      'state': state,
      'contact': contact,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'frequency': frequency,
      'approxPeople': approxPeople,
      'pickupFor': pickupFor,
      'couponCode': couponCode,
      'rewardPoints': rewardPoints,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

// --- Main Page: EDrivesPage ---
class EDrivesPage extends StatefulWidget {
  const EDrivesPage({Key? key}) : super(key: key);

  @override
  State<EDrivesPage> createState() => _EDrivesPageState();
}

class _EDrivesPageState extends State<EDrivesPage> {
  final TextEditingController _areaController = TextEditingController();
  bool _isLoading = false;
  List<EwasteDrive> _drives = [];

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _searchDrives() async {
    setState(() {
      _isLoading = true;
      _drives.clear();
    });
    final areaInput = _areaController.text;
    final apiKey = dotenv.env['SERP_API_KEY'];
    // Query tailored for e-waste drives
    final query = 'e-waste drive near $areaInput';
    final encodedQuery = Uri.encodeComponent(query);
    final serpUrl = Uri.parse(
      'https://serpapi.com/search.json?engine=google_maps&q=$encodedQuery&api_key=$apiKey',
    );
    debugPrint('SERP API Drive request URL: $serpUrl');
    try {
      final response = await http.get(serpUrl);
      final data = json.decode(response.body);
      debugPrint('SERP API Drive response: ${data.toString()}');
      if (data['local_results'] != null) {
        final results = data['local_results'] as List;
        List<EwasteDrive> drives = [];
        for (var result in results) {
          final title = result['title'] ?? 'Unknown Drive';
          final address = result['address'] ?? 'No address available';
          // Use maps_url or link as a fallback.
          final detailsLink = (result['maps_url'] != null && result['maps_url'].toString().isNotEmpty)
              ? result['maps_url']
              : (result['link'] ?? null);
          drives.add(EwasteDrive(title: title, address: address, detailsLink: detailsLink));
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
      debugPrint('Error during SERP API drive request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Show the pop-up card after search completes.
      _showContributionPopup();
    }
  }

  void _showContributionPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Contribute to the Earth!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie/recycling.json', height: 100),
              const SizedBox(height: 8),
              const Text("Wanna take the initiative and schedule an e-waste drive or pickup in your area?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                // Navigate to the scheduling form
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulePickupPage()),
                );
              },
              child: const Text("Yes, I'm interested"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No, not today"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.lightGreen[100];
    final buttonColor = Colors.green[800];

    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Waste Drives Near You"),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Enter Area/Address',
                border: OutlineInputBorder(),
              ),
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
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(drive.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(drive.address),
                      trailing: drive.detailsLink != null
                          ? IconButton(
                        icon: const Icon(Icons.open_in_new),
                        color: buttonColor,
                        onPressed: () => launchUrl(Uri.parse(drive.detailsLink!),
                            mode: LaunchMode.externalApplication),
                      )
                          : null,
                    ),
                  );
                },
              )
            else if (!_isLoading)
              const Text('No drives found.'),
            const SizedBox(height: 20),
            // Persistent button for scheduling a drive/pickup.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              icon: const Icon(Icons.event_available),
              label: const Text('Schedule an E-Waste Pickup/Drive'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulePickupPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Schedule Pickup / Drive Form Page ---
class SchedulePickupPage extends StatefulWidget {
  const SchedulePickupPage({Key? key}) : super(key: key);

  @override
  State<SchedulePickupPage> createState() => _SchedulePickupPageState();
}

class _SchedulePickupPageState extends State<SchedulePickupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  DateTime? _selectedDateTime;
  String _frequency = 'One time only';
  String _pickupFor = 'Self';

  // Frequency options.
  final List<String> _frequencyOptions = ['One time only', 'Once a month', 'Once in 3 months'];
  // Pickup for options.
  final List<String> _pickupForOptions = ['Self', 'Building', 'Locality'];

  // Method to pick date and time.
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

  // Method to submit form and store data in Firebase.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      // Create dummy coupon and reward points.
      final couponCode = "DUMMYCOUPON123";
      final rewardPoints = 50;

      final request = PickupRequest(
        name: _nameController.text,
        flatNo: _flatController.text,
        buildingName: _buildingController.text,
        streetAddress: _streetController.text,
        locality: _localityController.text,
        city: _cityController.text,
        state: _stateController.text,
        contact: _contactController.text,
        scheduledDateTime: _selectedDateTime!,
        frequency: _frequency,
        approxPeople: int.tryParse(_peopleController.text) ?? 0,
        pickupFor: _pickupFor,
        couponCode: couponCode,
        rewardPoints: rewardPoints,
      );

      try {
        // Save form data in Firestore.
        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .add(request.toMap());

        // Optionally, store incentive data in a separate collection.
        await FirebaseFirestore.instance.collection('incentives').add({
          'couponCode': couponCode,
          'rewardPoints': rewardPoints,
          'contact': _contactController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show success message with a Lottie animation.
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/success.json', height: 150),
                  const SizedBox(height: 8),
                  const Text(
                    "Pickup scheduled! You'll now be shown nearby centers to finalize the drive.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CenterSelectionPage(request: request),
                      ),
                    );
                  },
                  child: const Text("Continue"),
                ),
              ],
            );
          },
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select date/time')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _contactController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[800];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule E-Waste Pickup/Drive"),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Personal and address fields.
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _flatController,
                decoration: const InputDecoration(labelText: 'Flat No'),
                validator: (val) => val == null || val.isEmpty ? 'Enter flat number' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _buildingController,
                decoration: const InputDecoration(labelText: 'Building Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter building name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street Address'),
                validator: (val) => val == null || val.isEmpty ? 'Enter street address' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _localityController,
                decoration: const InputDecoration(labelText: 'Locality/Area'),
                validator: (val) => val == null || val.isEmpty ? 'Enter locality/area' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (val) => val == null || val.isEmpty ? 'Enter city' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (val) => val == null || val.isEmpty ? 'Enter state' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Enter contact number' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _peopleController,
                decoration: const InputDecoration(labelText: 'Approx. number of people in locality'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Enter a number' : null,
              ),
              const SizedBox(height: 16),
              // Date and time picker.
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
                    style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                    onPressed: _pickDateTime,
                    child: const Text('Pick Date & Time'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Frequency dropdown.
              DropdownButtonFormField<String>(
                value: _frequency,
                items: _frequencyOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _frequency = val;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 16),
              // Pickup for dropdown.
              DropdownButtonFormField<String>(
                value: _pickupFor,
                items: _pickupForOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _pickupFor = val;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Pickup for'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                onPressed: _submitForm,
                child: const Text('Schedule Pickup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
