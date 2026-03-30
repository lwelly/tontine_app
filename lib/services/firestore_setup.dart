import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreSetup {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _db.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> createGroup({
    required String groupName,
    required int monthlyAmount,
    required List<String> memberEmails,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user IDs from emails
    final memberIds = <String>[];

    // Add current user
    memberIds.add(user.uid);

    // Add other members (for now, we'll just add the current user)
    // In a real app, you'd search for users by email

    final groupDoc = await _db.collection('groups').add({
      'name': groupName,
      'groupName': groupName,
      'monthlyAmount': monthlyAmount,
      'members': memberIds,
      'creatorId': user.uid,
      'status': 'active',
      'currentTurn': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'totalMembers': memberIds.length,
      'isPublic': true, // Make groups discoverable
    });

    return groupDoc.id;
  }

  Future<void> recordPayment({
    required String groupId,
    required int amount,
    required String month,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _db.collection('payments').add({
      'groupId': groupId,
      'userId': user.uid,
      'amount': amount,
      'month': month,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'paid',
    });

    // Update group payment status
    await _db.collection('groups').doc(groupId).update({
      'lastPayment': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String message,
    String? groupId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'type': type,
      'message': message,
      'groupId': groupId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Sample data creation for testing
  Future<void> createSampleData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if sample data already exists
    final existingGroups = await _db
        .collection('groups')
        .where('creatorId', isEqualTo: user.uid)
        .where('groupName', isEqualTo: 'مجموعة التونتين الأولى')
        .get();

    if (existingGroups.docs.isNotEmpty) {
      return; // Sample data already exists
    }

    // Create a sample group
    final groupId = await createGroup(
      groupName: 'مجموعة التونتين الأولى',
      monthlyAmount: 5000,
      memberEmails: [user.email!],
    );

    // Create sample payment
    await recordPayment(
      groupId: groupId,
      amount: 5000,
      month: '2024-01',
    );

    // Create another sample payment
    await recordPayment(
      groupId: groupId,
      amount: 5000,
      month: '2024-02',
    );

    // Create sample notification
    await createNotification(
      userId: user.uid,
      type: 'payment_due',
      message: 'موعد الدفع لمجموعة التونتين الأولى',
      groupId: groupId,
    );

    debugPrint('Sample data created successfully!');
  }

  // Quick method to create sample group for testing
  Future<void> createQuickSampleGroup() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final groupId = await _db.collection('groups').add({
        'name': 'مجموعة التونتين التجريبية',
        'groupName': 'مجموعة التونتين التجريبية',
        'monthlyAmount': 5000,
        'members': [user.uid],
        'creatorId': user.uid,
        'status': 'active',
        'currentTurn': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'totalMembers': 1,
        'isPublic': true,
      });

      // Create a sample payment
      await _db.collection('payments').add({
        'groupId': groupId,
        'userId': user.uid,
        'amount': 5000,
        'month': '2024-01',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'paid',
      });

      debugPrint('Sample group created with ID: $groupId');
    } catch (e) {
      debugPrint('Error creating sample group: $e');
    }
  }

  // Fix existing unnamed groups
  Future<void> fixUnnamedGroups() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final unnamedGroups = await _db
          .collection('groups')
          .where('members', arrayContains: user.uid)
          .where('groupName', isNull: true)
          .get();

      for (var groupDoc in unnamedGroups.docs) {
        await _db.collection('groups').doc(groupDoc.id).update({
          'name': 'مجموعة التونتين المحدثة',
          'groupName': 'مجموعة التونتين المحدثة',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('Fixed ${unnamedGroups.docs.length} unnamed groups');
    } catch (e) {
      debugPrint('Error fixing unnamed groups: $e');
    }
  }
}
