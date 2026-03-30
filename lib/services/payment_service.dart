
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تحقق مما إذا كان العضو قد دفع لهذا الشهر بالفعل
  Future<bool> hasUserPaidThisMonth(String groupId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final now = DateTime.now();
    final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final query = await _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> pay({
    required String groupId,
    required int amount,
  }) async {
    final userId = _auth.currentUser!.uid;
    final now = DateTime.now();
    final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // التحقق: الدفع مرة واحدة فقط لكل شهر
    final existing = await _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('لقد قمت بالدفع لهذا الشهر مسبقاً');
    }

    Payment payment = Payment(
      groupId: groupId,
      userId: userId,
      month: month,
      amount: amount,
    );

    await _db.collection('payments').add(payment.toMap());

    // Create payment confirmation notification
    await _createPaymentNotification(groupId, amount, month);
  }

  Future<void> _createPaymentNotification(String groupId, int amount, String month) async {
    try {
      // Get group information
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final groupName = groupData['groupName'] ?? 'مجموعة غير مسمى';
      final userId = _auth.currentUser!.uid;

      // Create payment confirmation notification for the user
      await _db.collection('notifications').add({
        'userId': userId,
        'type': 'payment_confirmation',
        'groupId': groupId,
        'amount': amount,
        'month': month,
        'groupName': groupName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('ERROR: Error creating payment notification: $e');
    }
  }

  Stream<QuerySnapshot> paymentsByGroup(String groupId) {
    return _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .snapshots();
  }
}
