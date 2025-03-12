import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For mobile file handling
import 'package:flutter/foundation.dart'; // For kIsWeb

import 'recycling_info.dart'; // <-- We'll create this new page

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _imageUrl = ""; // For web image
  String _resultRaw = ''; // Raw JSON result from detection
  bool _isDetecting = false;

  // API details (use your own)
  final String apiKey = "1lnfSQNvSJxnSa9st5Jk";
  final String modelId = "e-waste-dataset-r0ojc/43";

  // Pick an image method
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        if (kIsWeb) {
          _imageUrl = pickedFile.path; 
        }
      });
    }
  }

  // Perform detection method
  Future<void> _performDetection() async {
    if (_image == null) return;

    setState(() {
      _isDetecting = true;
      _resultRaw = '';
    });

    final url = Uri.parse('https://detect.roboflow.com/$modelId?api_key=$apiKey&confidence=0.3');
    var request = http.MultipartRequest('POST', url);

    if (kIsWeb) {
      // Web: read bytes, then send
      var imageBytes = await _image!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'upload.jpg'));
    } else {
      // Mobile: send via file path
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      setState(() {
        _resultRaw = result;
        _isDetecting = false;
      });
      _handleDetectionResult(result);
    } else {
      final error = await response.stream.bytesToString();
      setState(() {
        _resultRaw = 'Error: ${response.statusCode}, Message: $error';
        _isDetecting = false;
      });
    }
  }

  // Parse detection JSON, then navigate to the next page
  void _handleDetectionResult(String rawJson) {
  try {
    final data = jsonDecode(rawJson);
    final predictions = data['predictions'];

    if (predictions != null && predictions.isNotEmpty) {
      // For simplicity, just use the first prediction
      final firstPrediction = predictions[0];
      final objectName = firstPrediction['class'] ?? 'Unknown';
      final objectWidth = firstPrediction['width'] ?? 0;
      final objectHeight = firstPrediction['height'] ?? 0;

      // Pass the entire detection result to RecyclingInfoPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecyclingInfoPage(
            objectName: objectName,
            objectWidth: objectWidth.toDouble(),
            objectHeight: objectHeight.toDouble(),
            fullDetectionResult: rawJson, // <-- Add this
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No objects detected!')),
      );
    }
  } catch (e) {
    print("Error parsing detection result: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick an Image"),
              ),
              SizedBox(height: 20),

              // Display selected image
              if (_image != null)
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: kIsWeb
                      ? Image.network(_imageUrl, fit: BoxFit.contain)
                      : Image.file(File(_image!.path), fit: BoxFit.contain),
                )
              else
                Text('No image selected.'),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isDetecting ? null : _performDetection,
                child: _isDetecting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Perform Detection"),
              ),
              SizedBox(height: 20),

              // Show raw JSON only if you want to debug
              if (_resultRaw.isNotEmpty)
                Text(
                  'Raw Detection Result: $_resultRaw',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
