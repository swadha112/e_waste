// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_stock.dart';
import '../models/transaction.dart';
import '../models/sip_plan.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Returns a stream of all stocks. Optionally filter by category.
  Stream<List<DeviceStock>> getStocks([String? category]) {
    Query query = _firestore.collection('stocks');
    if (category != null && category != "All") {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
        DeviceStock.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Returns trending devices stream based on a simple simulated metric.
  Stream<List<DeviceStock>> getTrendingDevices() {
    // Note: Here we use a dummy filtering logic.
    int threshold = 10;
    return _firestore.collection('stocks').snapshots().map((snapshot) {
      List<DeviceStock> allDevices = snapshot.docs
          .map((doc) =>
          DeviceStock.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      List<DeviceStock> trending = allDevices
          .where((device) => (device.demand - device.supply) > threshold)
          .toList();
      trending.sort((a, b) =>
          (b.demand - b.supply).compareTo(a.demand - a.supply));
      return trending;
    });
  }

  // Returns a market summary stream. Here we just compute average price and total count.
  Stream<Map<String, dynamic>> getMarketSummary() {
    return _firestore.collection('stocks').snapshots().map((snapshot) {
      List<DeviceStock> stocks = snapshot.docs
          .map((doc) =>
          DeviceStock.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      double totalPrice =
      stocks.fold(0, (sum, stock) => sum + stock.currentPrice);
      double avgPrice = stocks.isNotEmpty ? totalPrice / stocks.length : 0;
      return {
        'avgPrice': avgPrice,
        'totalDevices': stocks.length,
      };
    });
  }

  // Adds a new transaction document.
  Future<void> addTransaction(TransactionModel transaction) {
    return _firestore
        .collection('transactions')
        .add(transaction.toJson());
  }

  /// Returns the SIP plan for a specific user (by userId).
  /// If the document doesn't exist, yields null.
  Stream<SIPPlan?> getUserSIPPlan(String userId) {
    return _firestore
        .collection('sipPlans')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return SIPPlan.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Creates or updates the user's SIP plan document.
  Future<void> setUserSIPPlan(String userId, SIPPlan plan) async {
    await _firestore
        .collection('sipPlans')
        .doc(userId)
        .set(plan.toJson());
  }

  /// Updates only the 'invested' amount for a user's SIP plan.
  /// This is handy for lumpsum contributions.
  Future<void> updateSipInvested(String userId, double newInvested) async {
    await _firestore
        .collection('sipPlans')
        .doc(userId)
        .update({'invested': newInvested});
  }

}
