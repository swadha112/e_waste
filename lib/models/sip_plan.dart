// lib/models/sip_plan.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SIPPlan {
  final String targetDevice;
  final double targetPrice;
  final double invested;
  final String status; // e.g., "active", "completed"
  final DateTime creationTimestamp;

  SIPPlan({
    required this.targetDevice,
    required this.targetPrice,
    required this.invested,
    required this.status,
    required this.creationTimestamp,
  });

  factory SIPPlan.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['creationTimestamp'];
    DateTime parsedTimestamp;
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.parse(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return SIPPlan(
      targetDevice: json['targetDevice'],
      targetPrice: (json['targetPrice'] as num).toDouble(),
      invested: (json['invested'] as num).toDouble(),
      status: json['status'],
      creationTimestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetDevice': targetDevice,
      'targetPrice': targetPrice,
      'invested': invested,
      'status': status,
      'creationTimestamp': Timestamp.fromDate(creationTimestamp),
    };
  }
}
