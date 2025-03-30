import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'centerSelection.dart'; // Adjust path as needed

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
  final String pickupFor; // Now only "Building" or "Locality"
  final String couponCode;
  final int rewardPoints;
  final String status;

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
    this.status = "pending",
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
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

void main() {
  runApp(const MaterialApp(
    home: SchedulePickupPage(),
  ));
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
  String _pickupFor = 'Building'; // Default to one of the available options.

  // Frequency options.
  final List<String> _frequencyOptions = [
    'One time only',
    'Once a month',
    'Once in 3 months'
  ];

  // Pickup for options (removed "Self").
  final List<String> _pickupForOptions = [
    'Building',
    'Locality'
  ];

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
        final docRef = await FirebaseFirestore.instance
            .collection('pickup_requests')
            .add({
          ...request.toMap(),
          'status': 'pending', // Adding status here.
        });

        final pickupRequestId = docRef.id;

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
                        builder: (_) => CenterSelectionPage(
                          request: request,
                          pickupRequestId: pickupRequestId, // Pass the doc id here.
                        ),
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
