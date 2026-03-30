import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';
import 'invitation_service.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createGroup(TontineGroup group) async {
    final doc = await _db.collection('groups').add(group.toMap());

    // Add current user to group members
    await _db.collection('groups').doc(doc.id).update({
      'members': [_auth.currentUser!.uid]
    });
  }

  Stream<QuerySnapshot> myGroups() {
    return _db
        .collection('groups')
        .where('members', arrayContains: _auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> allPublicGroups() {
    return _db
        .collection('groups')
        .snapshots();
  }

  Future<void> joinGroup(String groupId) async {
    // Use invitation service instead of direct joining
    final invitationService = InvitationService();
    await invitationService.requestToJoinGroup(groupId);
  }

  Future<bool> isUserMember(String groupId) async {
    final userId = _auth.currentUser!.uid;
    final groupDoc = await _db.collection('groups').doc(groupId).get();
    final groupData = groupDoc.data() as Map<String, dynamic>;
    final members = List<String>.from(groupData['members'] ?? []);
    return members.contains(userId);
  }

  Future<void> leaveGroup(String groupId) async {
    final userId = _auth.currentUser!.uid;
    
    // Get group details
    final groupDoc = await _db.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception('المجموعة غير موجودة');
    }

    final groupData = groupDoc.data() as Map<String, dynamic>;
    final creatorId = groupData['creatorId'];
    final members = List<String>.from(groupData['members'] ?? []);

    // Check if user is the creator
    if (creatorId == userId) {
      throw Exception('لا يمكن لمنشئ المجموعة مغادرتها. يجب حذف المجموعة بدلاً من ذلك.');
    }

    // Check if user is a member
    if (!members.contains(userId)) {
      throw Exception('أنت لست عضوًا في هذه المجموعة');
    }

    // Remove user from members array
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
      'totalMembers': FieldValue.increment(-1),
    });

    // Create notification for group creator
    await _db.collection('notifications').add({
      'userId': creatorId,
      'type': 'member_left',
      'groupId': groupId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> deleteGroup(String groupId) async {
    final userId = _auth.currentUser!.uid;
    
    // Get group details
    final groupDoc = await _db.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception('المجموعة غير موجودة');
    }

    final groupData = groupDoc.data() as Map<String, dynamic>;
    final creatorId = groupData['creatorId'];

    // Check if user is the creator
    if (creatorId != userId) {
      throw Exception('فقط منشئ المجموعة يمكنه حذفها');
    }

    // Delete all related data
    final batch = _db.batch();

    // Delete group document
    batch.delete(_db.collection('groups').doc(groupId));

    // Delete all payments for this group
    final paymentsSnapshot = await _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .get();
    
    for (var payment in paymentsSnapshot.docs) {
      batch.delete(payment.reference);
    }

    // Delete all notifications related to this group
    final notificationsSnapshot = await _db
        .collection('notifications')
        .where('groupId', isEqualTo: groupId)
        .get();
    
    for (var notification in notificationsSnapshot.docs) {
      batch.delete(notification.reference);
    }

    // Commit the batch delete
    await batch.commit();
  }

  Future<DocumentSnapshot> getGroupDetails(String groupId) {
    return _db.collection('groups').doc(groupId).get();
  }

  Stream<QuerySnapshot> getGroupPayments(String groupId) {
    return _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<int> getTotalPaid(String groupId) async {
    final payments = await _db
        .collection('payments')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();
    
    int total = 0;
    for (var doc in payments.docs) {
      final raw = (doc.data())['amount'];
      if (raw is int) {
        total += raw;
      } else if (raw is num) {
        total += raw.toInt();
      }
    }
    return total;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final userId = _auth.currentUser!.uid;
    
    // Get user's groups
    final groupsSnapshot = await _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();

    final allGroupsSnapshot = await _db.collection('groups').get();
    
    int totalGroups = groupsSnapshot.docs.length;
    int publicGroups = allGroupsSnapshot.docs.length - totalGroups;
    if (publicGroups < 0) publicGroups = 0;
    int totalMembers = 0;
    int totalPaid = 0;
    
    for (var groupDoc in groupsSnapshot.docs) {
      final groupData = groupDoc.data();
      totalMembers += (groupData['members'] as List<dynamic>?)?.length ?? 0;
      
      // Get user's payments for this group
      final payments = await _db
          .collection('payments')
          .where('groupId', isEqualTo: groupDoc.id)
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var payment in payments.docs) {
        final raw = (payment.data())['amount'];
        if (raw is int) {
          totalPaid += raw;
        } else if (raw is num) {
          totalPaid += raw.toInt();
        }
      }
    }
    
    return {
      'totalGroups': totalGroups,
      'publicGroups': publicGroups,
      'totalMembers': totalMembers,
      'totalPaid': totalPaid,
    };
  }

  Stream<QuerySnapshot> getUserGroups(String userId) {
    return _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserPayments(String userId) {
    return _db
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getJoinRequests(String userId) {
    return _db
        .collection('join_requests')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> requestToJoinGroup(String groupId, String userId) async {
    await _db.collection('join_requests').add({
      'groupId': groupId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> acceptJoinRequest(String requestId) async {
    final requestDoc = await _db.collection('join_requests').doc(requestId).get();
    final requestData = requestDoc.data() as Map<String, dynamic>;
    
    // Add user to group members
    await _db.collection('groups').doc(requestData['groupId']).update({
      'members': FieldValue.arrayUnion([requestData['userId']]),
    });
    
    // Update request status
    await _db.collection('join_requests').doc(requestId).update({
      'status': 'accepted',
    });
    
    // Create notification
    await _db.collection('notifications').add({
      'userId': requestData['userId'],
      'type': 'join_request_accepted',
      'message': 'تم قبول طلب انضمامك للمجموعة',
      'groupId': requestData['groupId'],
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> rejectJoinRequest(String requestId) async {
    final requestDoc = await _db.collection('join_requests').doc(requestId).get();
    final requestData = requestDoc.data() as Map<String, dynamic>;
    
    // Update request status
    await _db.collection('join_requests').doc(requestId).update({
      'status': 'rejected',
    });
    
    // Create notification
    await _db.collection('notifications').add({
      'userId': requestData['userId'],
      'type': 'join_request_rejected',
      'message': 'تم رفض طلب انضمامك للمجموعة',
      'groupId': requestData['groupId'],
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
