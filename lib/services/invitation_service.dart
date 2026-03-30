import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Request to join a group (creates invitation request)
  Future<void> requestToJoinGroup(String groupId) async {
    final userId = _auth.currentUser!.uid;

    // Check if user already has a pending request
    final existingRequest = await _db
        .collection('invitations')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('لديك بالفعل طلب انضمام معلق لهذه المجموعة');
    }

    // Check if user is already a member
    final groupDoc = await _db.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception('المجموعة غير موجودة');
    }

    final groupData = groupDoc.data() as Map<String, dynamic>;
    final members = List<String>.from(groupData['members'] ?? []);
    
    if (members.contains(userId)) {
      throw Exception('أنت بالفعل عضو في هذه المجموعة');
    }

    // Create invitation request
    final resolvedGroupName =
        (groupData['name'] ?? groupData['groupName'] ?? 'مجموعة غير مسمى').toString();
    final invitationData = {
      'groupId': groupId,
      'userId': userId,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
      'groupName': resolvedGroupName,
      'groupCreatorId': groupData['creatorId'],
    };

    await _db.collection('invitations').add(invitationData);

    // Notify group members about the request
    final membersToNotify = members.where((memberId) => memberId != userId).toList();
    
    for (final memberId in membersToNotify) {
      await _db.collection('notifications').add({
        'userId': memberId,
        'type': 'join_request',
        'groupId': groupId,
        'requesterId': userId,
        'groupName': resolvedGroupName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  // Get pending requests for a group
  Stream<QuerySnapshot> getPendingRequests(String groupId) {
    // Remove orderBy to avoid index requirement temporarily
    final stream = _db
        .collection('invitations')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
    return stream;
  }

  // Get user's pending requests
  Stream<QuerySnapshot> getUserPendingRequests() {
    final userId = _auth.currentUser!.uid;
    // Remove orderBy to avoid index requirement temporarily
    return _db
        .collection('invitations')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Approve a join request
  Future<void> approveRequest(String invitationId, String groupId, String requesterId) async {
    final batch = _db.batch();

    // Update invitation status
    final invitationRef = _db.collection('invitations').doc(invitationId);
    batch.update(invitationRef, {
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': _auth.currentUser!.uid,
    });

    // Add user to group members
    final groupRef = _db.collection('groups').doc(groupId);
    batch.update(groupRef, {
      'members': FieldValue.arrayUnion([requesterId]),
      'totalMembers': FieldValue.increment(1),
    });

    // Create notification for the approved user
    await _db.collection('notifications').add({
      'userId': requesterId,
      'type': 'join_approved',
      'groupId': groupId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Commit the batch
    await batch.commit();
  }

  // Reject a join request
  Future<void> rejectRequest(String invitationId, String groupId, String requesterId) async {
    // Update invitation status
    await _db.collection('invitations').doc(invitationId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': _auth.currentUser!.uid,
    });

    // Create notification for the rejected user
    await _db.collection('notifications').add({
      'userId': requesterId,
      'type': 'join_rejected',
      'groupId': groupId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Check if user has pending request for a group
  Future<bool> hasPendingRequest(String groupId) async {
    final userId = _auth.currentUser!.uid;

    final request = await _db
        .collection('invitations')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return request.docs.isNotEmpty;
  }
}
