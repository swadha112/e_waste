import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class RecyclingInfoPage extends StatefulWidget {
  final String objectName;
  final double objectWidth;
  final double objectHeight;
  final String fullDetectionResult; // Entire JSON from object detection

  const RecyclingInfoPage({
    Key? key,
    required this.objectName,
    required this.objectWidth,
    required this.objectHeight,
    required this.fullDetectionResult,
  }) : super(key: key);

  @override
  _RecyclingInfoPageState createState() => _RecyclingInfoPageState();
}

class _RecyclingInfoPageState extends State<RecyclingInfoPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _parsedResult;
  String? _error;

  // Replace with your actual OpenAI API key
  String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _callOpenAi();
  }

  Future<void> _callOpenAi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Refined system message (prompt) to request price breakdown
    final systemMessage = """
You are an AI assistant that specializes in analyzing e-waste detection results. 
You receive the entire JSON from an object detection API, and you must:
1. Identify the device name, its width, and its height.
2. Classify each device component into "recyclable" or "non-recyclable".
3. Provide the price in Indian rupees (numeric value only) for any recyclable components, in a field named "priceInRupees".
4. Provide the source for that price in a field named "source".
5. If the component is non-recyclable, provide a disposal suggestion in a field named "disposal".
6. If a price breakdown is available, provide a detailed price decomposition under "priceBreakdown" in the format:
   - {"component": "component_name", "priceInRupees": price}.
7. Return only valid JSON in the format:

{
  "objectName": "...",
  "width": ...,
  "height": ...,
  "components": [
    {
      "name": "...",
      "recyclable": true/false,
      "priceInRupees": 0,
      "source": "...",
      "disposal": "...",
      "priceBreakdown": [
        {"component": "component_name", "priceInRupees": price},
        ...
      ]
    },
    ...
  ]
}
""";

    // Include the raw detection results + known name/width/height
    final userMessage = """
Here is the raw detection result JSON:
${widget.fullDetectionResult}

We also know from the detection page that the main object is named "${widget.objectName}", 
with width = ${widget.objectWidth}, height = ${widget.objectHeight}.

Please classify its components as requested, in valid JSON only.
""";

    final messages = [
      {"role": "system", "content": systemMessage},
      {"role": "user", "content": userMessage},
    ];

    final requestBody = {
      "model": "gpt-3.5-turbo",
      "messages": messages,
      "temperature": 0.7,
      "max_tokens": 512,
    };

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data["choices"] as List<dynamic>;
        if (choices.isNotEmpty) {
          final content = choices[0]["message"]["content"] ?? "";
          // Attempt to parse the model's output as JSON
          try {
            final parsed = jsonDecode(content);
            setState(() {
              _parsedResult = parsed;
            });
          } catch (jsonError) {
            setState(() {
              // The model's response might not be valid JSON
              _error = "Failed to parse model output as JSON:\n$content";
            });
          }
        } else {
          setState(() {
            _error = "No response from model.";
          });
        }
      } else {
        setState(() {
          _error = "Error: ${response.statusCode}, ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResults() {
    if (_parsedResult == null) {
      return Text("No recycling information available.");
    }

    // Fallback to detection page values if the model doesn't return them
    final objectName = _parsedResult!["objectName"] ?? widget.objectName;
    final width = _parsedResult!["width"] ?? widget.objectWidth;
    final height = _parsedResult!["height"] ?? widget.objectHeight;
    final components = _parsedResult!["components"] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summaries
          Text(
            'Device: $objectName',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Dimensions: (width: $width, height: $height)',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),

          Text(
            'Components:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: components.length,
            itemBuilder: (context, index) {
              final comp = components[index];
              final name = comp["name"] ?? "Unknown";
              final recyclable = comp["recyclable"] ?? false;
              final priceInRupees = comp["priceInRupees"] ?? 0;
              final source = comp["source"] ?? "N/A";
              final disposal = comp["disposal"] ?? "N/A";
              final priceBreakdown = comp["priceBreakdown"] ?? [];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recyclable)
                        Text(
                          'Recyclable\nPrice: ₹$priceInRupees (Source: $source)',
                          style: TextStyle(height: 1.4),
                        )
                      else
                        Text(
                          'Non-Recyclable\nDisposal: $disposal',
                          style: TextStyle(height: 1.4),
                        ),
                      if (priceBreakdown.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Breakdown:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              for (var breakdown in priceBreakdown)
                                Text(
                                  '${breakdown["component"]}: ₹${breakdown["priceInRupees"]}',
                                  style: TextStyle(height: 1.4),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  leading: Icon(
                    recyclable ? Icons.check_circle : Icons.cancel,
                    color: recyclable ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycling Information'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
            ? SingleChildScrollView(child: Text(_error!))
            : _buildResults(),
      ),
    );
  }
}
