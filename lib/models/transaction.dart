// lib/models/transaction.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String orderType;
  final String deviceName;
  final String deviceAge;
  final int quantity;
  final DateTime timestamp;

  TransactionModel({
    required this.orderType,
    required this.deviceName,
    required this.deviceAge,
    required this.quantity,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      orderType: json['orderType'],
      deviceName: json['deviceName'],
      deviceAge: json['deviceAge'],
      quantity: json['quantity'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType,
      'deviceName': deviceName,
      'deviceAge': deviceAge,
      'quantity': quantity,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
