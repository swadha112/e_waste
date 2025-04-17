// lib/services/import_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImportService {
  /// Imports stocks data from a JSON file in the assets folder into Firestore.
  static Future<void> importStocksData() async {
    try {
      // Load the JSON file as a string.
      final String jsonString =
      await rootBundle.loadString('assets/stocks.json');

      // Decode the JSON string to a List<dynamic>.
      final List<dynamic> jsonList = json.decode(jsonString);

      // Get an instance of Firestore.
      final CollectionReference stocksCollection =
      FirebaseFirestore.instance.collection('stocks');

      // Optionally, you can clear existing data if needed:
      // for (var doc in (await stocksCollection.get()).docs) {
      //   await doc.reference.delete();
      // }

      // Iterate over the JSON list and add each document.
      for (var jsonItem in jsonList) {
        // You can also use .doc(someId).set(jsonItem) if you wish to control document IDs.
        await stocksCollection.add(jsonItem as Map<String, dynamic>);
      }

      print("Stocks data imported successfully.");
    } catch (e) {
      print("Error importing stocks data: $e");
    }
  }
}
