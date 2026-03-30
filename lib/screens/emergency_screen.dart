import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/emergency_service.dart';

class EmergencyScreen extends StatelessWidget {
  final String groupId;
  EmergencyScreen({super.key, required this.groupId});

  final service = EmergencyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urgences collectives')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergencies')
            .where('groupId', isEqualTo: groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Aucune urgence'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final e = docs[i];

              return Card(
                child: ListTile(
                  title: Text(e['reason']),
                  subtitle: Text('Montant: ${e['amount']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () =>
                            service.vote(emergencyId: e.id, userId: 'USER_ID', approve: true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_down),
                        onPressed: () =>
                            service.vote(emergencyId: e.id, userId: 'USER_ID', approve: false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
