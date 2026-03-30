import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class MyPaymentsScreen extends StatelessWidget {
  const MyPaymentsScreen({super.key});

  Stream<QuerySnapshot> _paymentsStream({
    required String userId,
    required bool ordered,
  }) {
    var q = FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .limit(50);

    if (ordered) {
      q = q.orderBy('paidAt', descending: true);
    }

    return q.snapshots();
  }

  List<QueryDocumentSnapshot> _sortDocsByPaidAtDesc(List<QueryDocumentSnapshot> docs) {
    final sorted = List<QueryDocumentSnapshot>.from(docs);

    DateTime? resolveDt(QueryDocumentSnapshot d) {
      final data = d.data() as Map<String, dynamic>;
      final v = data['paidAt'];
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    sorted.sort((a, b) {
      final ad = resolveDt(a);
      final bd = resolveDt(b);
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.myPaymentsTitle),
      ),
      body: SafeArea(
        child: userId == null
            ? _EmptyState(
                icon: Icons.payments_rounded,
                title: l10n.loginToAccessFeaturesTitle,
                subtitle: l10n.loginToViewPaymentsHistory,
              )
            : StreamBuilder<QuerySnapshot>(
                stream: _paymentsStream(userId: userId, ordered: true),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snap.hasError) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: _paymentsStream(userId: userId, ordered: false),
                      builder: (context, fallbackSnap) {
                        if (fallbackSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (fallbackSnap.hasError) {
                          return _EmptyState(
                            icon: Icons.error_outline_rounded,
                            title: l10n.paymentsHistoryLoadFailed,
                            subtitle: fallbackSnap.error.toString(),
                          );
                        }

                        if (!fallbackSnap.hasData ||
                            fallbackSnap.data!.docs.isEmpty) {
                          return _EmptyState(
                            icon: Icons.payments_rounded,
                            title: l10n.noPaymentsYet,
                            subtitle: l10n.paymentsWillAppearHere,
                          );
                        }

                        final orderedDocs = _sortDocsByPaidAtDesc(
                          fallbackSnap.data!.docs.cast<QueryDocumentSnapshot>(),
                        );

                        return _PaymentsList(docs: orderedDocs);
                      },
                    );
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return _EmptyState(
                      icon: Icons.payments_rounded,
                      title: l10n.noPaymentsYet,
                      subtitle: l10n.paymentsWillAppearHere,
                    );
                  }

                  final orderedDocs =
                      snap.data!.docs.cast<QueryDocumentSnapshot>();
                  return _PaymentsList(docs: orderedDocs);
                },
              ),
      ),
    );
  }
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({required this.docs});

  final List<QueryDocumentSnapshot> docs;

  Future<Map<String, String>> _fetchGroupNameMap() async {
    final ids = <String>{};
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final gid = (data['groupId'] ?? '').toString();
      if (gid.isNotEmpty) ids.add(gid);
    }

    if (ids.isEmpty) return {};

    final results = <String, String>{};
    final list = ids.toList();
    for (int i = 0; i < list.length; i += 10) {
      final chunk = list.sublist(i, (i + 10) > list.length ? list.length : (i + 10));
      final snap = await FirebaseFirestore.instance
          .collection('groups')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['name'] ?? data['groupName'] ?? '').toString();
        if (name.isNotEmpty) results[doc.id] = name;
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _fetchGroupNameMap(),
      builder: (context, snap) {
        final groupNameMap = snap.data ?? const {};

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final l10n = AppLocalizations.of(context)!;

            final rawAmount = data['amount'];
            final amount = (rawAmount is num)
                ? rawAmount.toStringAsFixed(0)
                : rawAmount?.toString() ?? '';

            final groupId = (data['groupId'] ?? '').toString();
            final localName =
                (data['groupName'] ?? data['name'] ?? '').toString();
            final resolvedName =
                (groupNameMap[groupId] ?? localName).trim();
            final groupName =
                resolvedName.isEmpty ? l10n.groupGeneric : resolvedName;

            final month = (data['month'] ?? '').toString();
            final year = (data['year'] ?? '').toString();

            final paidAt = data['paidAt'];
            final dt = (paidAt is Timestamp)
                ? paidAt.toDate()
                : (paidAt is DateTime)
                    ? paidAt
                    : (paidAt is String)
                        ? DateTime.tryParse(paidAt)
                        : null;

            final dateText =
                (dt == null) ? '' : '${dt.day}/${dt.month}/${dt.year}';

            final monthText = (month.isNotEmpty && year.isNotEmpty)
                ? '$month/$year'
                : (month.isNotEmpty ? month : '');

            final subtitleParts = <String>[
              if (amount.isNotEmpty) '$amount MRU',
              if (monthText.isNotEmpty) monthText,
              if (dateText.isNotEmpty) dateText,
            ];

            return Card(
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                title: Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                subtitle: Text(
                  subtitleParts.isEmpty ? ' ' : subtitleParts.join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
