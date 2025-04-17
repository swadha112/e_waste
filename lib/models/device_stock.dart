// lib/models/device_stock.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceStock {
  final String name;
  final String symbol;
  final String category;
  int currentPrice;
  List<double> history;
  int supply;
  int demand;
  final DateTime lastUpdated;

  DeviceStock({
    required this.name,
    required this.symbol,
    required this.category,
    required this.currentPrice,
    required this.history,
    required this.supply,
    required this.demand,
    required this.lastUpdated,
  });

  factory DeviceStock.fromJson(Map<String, dynamic> json) {
    final rawLastUpdated = json['lastUpdated'];
    DateTime parsedDate;

    if (rawLastUpdated is Timestamp) {
      // If it's actually a Timestamp, convert normally
      parsedDate = rawLastUpdated.toDate();
    } else if (rawLastUpdated is String) {
      // If it's a string like "2025-04-16T12:00:00Z", parse it
      parsedDate = DateTime.parse(rawLastUpdated);
    } else {
      // Fallback if missing or unknown
      parsedDate = DateTime.now();
    }

    return DeviceStock(
      name: json['name'],
      symbol: json['symbol'],
      category: json['category'],
      currentPrice: json['currentPrice'],
      history: List<double>.from(json['history'].map((x) => x.toDouble())),
      supply: json['supply'],
      demand: json['demand'],
      lastUpdated: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'category': category,
      'currentPrice': currentPrice,
      'history': history,
      'supply': supply,
      'demand': demand,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
