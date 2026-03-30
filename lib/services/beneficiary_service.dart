import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BeneficiaryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _generateOrderIfNeeded(String groupId, List<String> memberIds) async {
    final existing = await _db
        .collection('beneficiary_order')
        .where('groupId', isEqualTo: groupId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    final shuffled = List<String>.from(memberIds)..shuffle();

    final batch = _db.batch();
    for (int i = 0; i < shuffled.length; i++) {
      batch.set(_db.collection('beneficiary_order').doc(), {
        'groupId': groupId,
        'userId': shuffled[i],
        'position': i,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> performAutomaticDraw(String groupId) async {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final groupRef = _db.collection('groups').doc(groupId);

    final groupSnap = await groupRef.get();
    if (!groupSnap.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupSnap.data() as Map<String, dynamic>;
    final members = List<String>.from(groupData['members'] ?? []);
    if (members.isEmpty) {
      throw Exception('No members in group');
    }

    final creatorId = (groupData['creatorId'] ?? '').toString();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (creatorId.isEmpty || currentUserId == null || creatorId != currentUserId) {
      throw Exception('Only group creator can perform draw');
    }

    final paymentsSnap = await _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .where('month', isEqualTo: currentMonth)
        .get();

    final paidUserIds = <String>{};
    for (final d in paymentsSnap.docs) {
      final data = d.data();
      final uid = data['userId'];
      if (uid is String && uid.isNotEmpty) paidUserIds.add(uid);
    }

    final allMembersPaid = members.every(paidUserIds.contains);
    if (!allMembersPaid) {
      throw Exception('All members must pay before draw');
    }

    await _generateOrderIfNeeded(groupId, members);

    final orderSnap = await _db
        .collection('beneficiary_order')
        .where('groupId', isEqualTo: groupId)
        .get();

    final ordered = orderSnap.docs
      ..sort((a, b) {
        final ap = (a.data()['position'] is num)
            ? (a.data()['position'] as num).toInt()
            : int.tryParse(a.data()['position']?.toString() ?? '') ?? 0;
        final bp = (b.data()['position'] is num)
            ? (b.data()['position'] as num).toInt()
            : int.tryParse(b.data()['position']?.toString() ?? '') ?? 0;
        return ap.compareTo(bp);
      });

    final orderedMemberIds = <String>[];
    for (final d in ordered) {
      final data = d.data();
      final uid = (data['userId'] ?? data['userid'] ?? '').toString();
      if (uid.isNotEmpty) orderedMemberIds.add(uid);
    }

    final cycle = orderedMemberIds.isEmpty ? members : orderedMemberIds;

    await _db.runTransaction((tx) async {
      final freshGroupSnap = await tx.get(groupRef);
      if (!freshGroupSnap.exists) {
        throw Exception('Group not found');
      }

      final freshGroupData = freshGroupSnap.data() as Map<String, dynamic>;
      final rawTurn = freshGroupData['currentTurn'];
      final currentTurn = (rawTurn is num)
          ? rawTurn.toInt()
          : int.tryParse(rawTurn?.toString() ?? '') ?? 0;
      final safeTurn = (currentTurn < 0) ? 0 : currentTurn % cycle.length;
      final selectedUserId = cycle[safeTurn];

      final existing = await _db
          .collection('monthly_beneficiaries')
          .where('groupId', isEqualTo: groupId)
          .where('month', isEqualTo: currentMonth)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return;
      }

      await _db.collection('monthly_beneficiaries').add({
        'groupId': groupId,
        'month': currentMonth,
        'userId': selectedUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(groupRef, {
        'currentTurn': (safeTurn + 1) % cycle.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    });
  }

  Stream<QuerySnapshot> currentBeneficiary(String groupId) {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    
    return _db
        .collection('monthly_beneficiaries')
        .where('groupId', isEqualTo: groupId)
        .where('month', isEqualTo: currentMonth)
        .snapshots();
  }

  Stream<QuerySnapshot> allMonthlyBeneficiaries(String groupId) {
    return _db
        .collection('monthly_beneficiaries')
        .where('groupId', isEqualTo: groupId)
        .snapshots();
  }

  Future<bool> hasMonthlyBeneficiary(String groupId) async {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    
    final existing = await _db
        .collection('monthly_beneficiaries')
        .where('groupId', isEqualTo: groupId)
        .where('month', isEqualTo: currentMonth)
        .get();
    
    return existing.docs.isNotEmpty;
  }
}
