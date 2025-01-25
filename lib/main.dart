import 'package:flutter/material.dart';

void main() {
  runApp(EWasteApp());
}

class EWasteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoByte', // App name
      theme: ThemeData(
        primarySwatch: Colors.green, // Solid green theme
      ),
      home: HomePage(), // Initial screen
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoByte'), // App bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/EcoByte.png', // Path to the image
              width: 100, // Adjust the size as needed
              height: 100,
            ),
            SizedBox(height: 20), // Spacing between the image and text
            Text(
              'Welcome to my project',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

