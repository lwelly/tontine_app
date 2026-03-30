import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyService {
  final _db = FirebaseFirestore.instance;

  Future<void> createEmergency({
    required String groupId,
    required String userId,
    required String reason,
    required int amount,
  }) async {
    await _db.collection('emergencies').add({
      'groupId': groupId,
      'requesterId': userId,
      'reason': reason,
      'amount': amount,
      'yesVotes': [],
      'noVotes': [],
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> vote({
    required String emergencyId,
    required String userId,
    required bool approve,
  }) async {
    final ref = _db.collection('emergencies').doc(emergencyId);

    await ref.update({
      approve
          ? 'yesVotes'
          : 'noVotes': FieldValue.arrayUnion([userId])
    });
  }
}
