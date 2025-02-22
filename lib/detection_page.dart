import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For image handling

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _result = ''; // To display the result of the detection

  // API details (use your API Key here)
  final String apiKey = "1lnfSQNvSJxnSa9st5Jk"; // Your API key here
  final String modelId = "e-waste-dataset-r0ojc/43"; // Your model ID
  final String url = "https://detect.roboflow.com"; // Roboflow Hosted API

  // Method to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Method to perform detection
  Future<void> _performDetection() async {
    if (_image == null) return; // No image selected

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://detect.roboflow.com/$modelId?api_key=$apiKey&confidence=0.3'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      setState(() {
        _result = result;
      });
    } else {
      final error = await response.stream.bytesToString();
      setState(() {
        _result = 'Error: ${response.statusCode}, Message: $error';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick an Image"),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(File(_image!.path)) // Display the selected image
                : Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performDetection,
              child: Text("Perform Detection"),
            ),
            SizedBox(height: 20),
            _result.isEmpty ? Container() : Text('Detection Result: $_result'),
          ],
        ),
      ),
    );
  }
}
