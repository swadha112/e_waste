import 'package:flutter/material.dart';

class PersonalDrivePage extends StatelessWidget {
  const PersonalDrivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule a Pick Up'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text('Personal Drive Page'),
      ),
    );
  }
}
