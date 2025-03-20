import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'recycling_info.dart';
import 'dart:typed_data';
//import 'dart:html' as html; // For web file handling
import 'package:permission_handler/permission_handler.dart'; // Add this line

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Uint8List? _webImageBytes; // Store image bytes for web
  String _resultRaw = '';
  bool _isDetecting = false;
  bool _useTextInput = false;

  final TextEditingController _objectNameController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();

  final String roboflowApiKey = "1lnfSQNvSJxnSa9st5Jk";
  final String roboflowModelId = "e-waste-dataset-r0ojc/43";
  final String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? "";

  // Function to pick an image from the gallery or use the camera
  Future<void> _pickImage(bool fromCamera) async {
    if (fromCamera) {
      // Request camera permission before opening the camera
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (pickedFile != null) {
          setState(() {
            _image = pickedFile;
          });

          if (kIsWeb) {
            final imageBytes = await pickedFile.readAsBytes();
            setState(() {
              _webImageBytes = imageBytes; // Store for display in Image.memory
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera permission denied')),
        );
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });

        if (kIsWeb) {
          final imageBytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = imageBytes; // Store for display in Image.memory
          });
        }
      }
    }
  }

  Future<void> _performDetection() async {
    if (_image == null) return;

    setState(() {
      _isDetecting = true;
      _resultRaw = '';
    });

    final url = Uri.parse('https://detect.roboflow.com/$roboflowModelId?api_key=$roboflowApiKey&confidence=0.3');
    var request = http.MultipartRequest('POST', url);

    if (kIsWeb) {
      var imageBytes = await _image!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'upload.jpg'));
    } else {
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

  void _handleDetectionResult(String rawJson) {
    try {
      final data = jsonDecode(rawJson);
      final predictions = data['predictions'];

      if (predictions != null && predictions.isNotEmpty) {
        final firstPrediction = predictions[0];
        final objectName = firstPrediction['class'] ?? 'Unknown';
        final objectWidth = firstPrediction['width'] ?? 0;
        final objectHeight = firstPrediction['height'] ?? 0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecyclingInfoPage(
              objectName: objectName,
              objectWidth: objectWidth.toDouble(),
              objectHeight: objectHeight.toDouble(),
              fullDetectionResult: rawJson,
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

  Future<void> _fetchObjectInfoFromOpenAI() async {
    final objectName = _objectNameController.text.trim();
    final modelName = _modelNameController.text.trim().isNotEmpty ? _modelNameController.text.trim() : "Unknown Model";

    if (objectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an object name.')),
      );
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "Provide detailed information on the object: $objectName using model: $modelName."}
        ],
        "temperature": 0.7,
        "max_tokens": 256,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final generatedText = result['choices'][0]['message']['content'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecyclingInfoPage(
            objectName: objectName,
            objectWidth: 0,
            objectHeight: 0,
            fullDetectionResult: generatedText,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details from OpenAI.')),
      );
    }

    setState(() {
      _isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Waste Detection'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToggleButtons(
              children: [Text("Image Detection"), Text("Text Input")],
              isSelected: [_useTextInput == false, _useTextInput == true],
              onPressed: (index) {
                setState(() {
                  _useTextInput = index == 1;
                });
              },
            ),
            SizedBox(height: 20),
            _useTextInput
                ? Column(
              children: [
                TextField(controller: _objectNameController, decoration: InputDecoration(labelText: 'Object Name')),
                TextField(controller: _modelNameController, decoration: InputDecoration(labelText: 'Model Name (optional)')),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isDetecting ? null : _fetchObjectInfoFromOpenAI,
                  child: _isDetecting ? CircularProgressIndicator(color: Colors.white) : Text("Get Info"),
                ),
              ],
            )
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () => _pickImage(false),
                        child: Text("Pick from Gallery")
                    ),
                    ElevatedButton(
                        onPressed: () => _pickImage(true),
                        child: Text("Use Camera")
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (_image != null) kIsWeb ? Image.memory(_webImageBytes!) : Image.file(File(_image!.path)),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _isDetecting ? null : _performDetection, child: Text("Perform Detection")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
