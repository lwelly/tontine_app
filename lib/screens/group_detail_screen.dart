import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

import 'payment_screen.dart';
import 'beneficiary_screen.dart';
import 'join_requests_screen.dart';
/// ================= GROUP DETAIL SCREEN =================

class GroupDetailScreen extends StatelessWidget {

  final String groupId;
  final int monthlyAmount;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.monthlyAmount,
  });


  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.groupDetailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    groupId: groupId,
                    monthlyAmount: monthlyAmount,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ================= CONTENT =================

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .snapshots(),
                builder: (context, snapshot) {

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {

                        return const Center(
                          child: CircularProgressIndicator(),
                        );

                      }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(
                        child: Text(l10n.groupNotFound),
                      );
                    }

                      final group =
                      snapshot.data!.data()
                      as Map<String, dynamic>;

                      final members =
                      List<String>.from(group['members'] ?? []);

                      final creatorId = (group['creatorId'] ?? '').toString();
                      final isCreator = creatorId.isNotEmpty &&
                          creatorId == FirebaseAuth.instance.currentUser?.uid;

                      final groupName =
                          (group['name'] ?? group['groupName'] ?? l10n.groupGeneric).toString();

                      final now = DateTime.now();
                      final currentMonth =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}";

                      final currentTurn =
                          group['currentTurn'] ?? 0;

                      final totalTurns =
                          members.length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildGroupInfoCard(context, group, l10n),
                        const SizedBox(height: 20),
                        _buildMembersCard(members, currentTurn, l10n),
                        const SizedBox(height: 20),
                        _buildTurnCard(currentTurn, totalTurns, l10n),
                        const SizedBox(height: 20),
                        _buildButtons(
                          context,
                          l10n,
                          isCreator: isCreator,
                          groupName: groupName,
                          members: members,
                          currentMonth: currentMonth,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );

  }



  /// ================= GROUP INFO =================

  Widget _buildGroupInfoCard(
      BuildContext context,
      Map<String, dynamic> group,
      AppLocalizations l10n,
      ) {

    final resolvedGroupName =
        (group['name'] ?? group['groupName'] ?? '').toString();
    final rawAmount = group['monthlyAmount'];
    final resolvedAmount = (rawAmount is num)
        ? rawAmount.toInt()
        : int.tryParse(rawAmount?.toString() ?? '') ?? monthlyAmount;

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [
            _row(l10n.groupNameLabel, resolvedGroupName),
            _row(l10n.amount, "$resolvedAmount MRU"),
            _row(l10n.members, "${group['members']?.length ?? 0}"),
            _row(l10n.status, (group['status'] ?? "").toString()),
          ],

        ),

      ),

    );

  }



  /// ================= MEMBERS =================

  Widget _buildMembersCard(
      List<String> members,
      int currentTurn,
      AppLocalizations l10n,
      ) {

    return Card(

      child: Column(

        children: List.generate(

          members.length,

              (index) {

            final memberId = members[index];

            final isCurrent =
                index == currentTurn;

            return FutureBuilder<DocumentSnapshot>(

              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(memberId)
                  .get(),

              builder: (context, snapshot) {

                String name = l10n.loading;

                if (snapshot.hasData) {

                  final data =
                  snapshot.data!.data()
                  as Map<String, dynamic>?;

                  name = (data?['name'] ?? data?['email'] ?? l10n.userGeneric).toString();

                }

                return ListTile(

                  title: Text(name),

                  trailing: isCurrent
                      ? const Icon(Icons.star)
                      : null,

                );

              },

            );

          },

        ),

      ),

    );

  }



  /// ================= TURN CARD =================

  Widget _buildTurnCard(
      int currentTurn,
      int totalTurns,
      AppLocalizations l10n,
      ) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Text(l10n.turnOfTotal(currentTurn + 1, totalTurns)),

            LinearProgressIndicator(

              value: totalTurns == 0
                  ? 0
                  : (currentTurn + 1) / totalTurns,

            ),

          ],

        ),

      ),

    );

  }



  /// ================= BUTTONS =================

  Widget _buildButtons(
      BuildContext context,
      AppLocalizations l10n,
      {required bool isCreator,
      required String groupName,
      required List<String> members,
      required String currentMonth,
      }
      ) {

    final payAction = _ActionItem(
      title: l10n.paymentTitle,
      subtitle: l10n.paymentActionSubtitle,
      icon: Icons.payments_rounded,
      color: AppColors.success,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              groupId: groupId,
              monthlyAmount: monthlyAmount,
            ),
          ),
        );
      },
    );

    final joinRequestsAction = _ActionItem(
      title: l10n.joinRequestsTitle,
      subtitle: l10n.joinRequestsSubtitle,
      icon: Icons.how_to_reg_rounded,
      color: AppColors.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinRequestsScreen(
              groupId: groupId,
              groupName: groupName,
            ),
          ),
        );
      },
    );

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('groupId', isEqualTo: groupId)
          .where('month', isEqualTo: currentMonth)
          .get(),
      builder: (context, paySnap) {
        final paidUserIds = <String>{};
        if (paySnap.hasData) {
          for (final d in paySnap.data!.docs) {
            final data = d.data() as Map<String, dynamic>;
            final uid = data['userId'];
            if (uid is String && uid.isNotEmpty) {
              paidUserIds.add(uid);
            }
          }
        }

        final allMembersPaid = members.isNotEmpty &&
            members.every((m) => paidUserIds.contains(m));

        final paidCount = members.where((m) => paidUserIds.contains(m)).length;
        final totalCount = members.length;

        final unpaidIds = members.where((m) => !paidUserIds.contains(m)).toList();

        final canDraw = isCreator && allMembersPaid;

        final drawAction = _ActionItem(
          title: l10n.drawTitle,
          subtitle: canDraw
              ? l10n.drawForMonth(currentMonth)
              : (isCreator ? l10n.waitingAllMembersToPay : l10n.creatorOnly),
          icon: Icons.emoji_events_rounded,
          color: AppColors.warning,
          enabled: canDraw,
          onTap: () {
            if (!isCreator) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.drawCreatorOnlySnackbar),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            if (!allMembersPaid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.drawRequiresAllPaidSnackbar),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeneficiaryScreen(
                  groupId: groupId,
                ),
              ),
            );
          },
        );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (allMembersPaid ? AppColors.success : AppColors.warning)
                      .withAlpha(40),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  initiallyExpanded: false,
                  trailing: SizedBox(
                    width: 90,
                    child: LinearProgressIndicator(
                      value: totalCount == 0 ? 0 : paidCount / totalCount,
                      backgroundColor: Colors.black.withAlpha(10),
                      color: allMembersPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        allMembersPaid ? Icons.check_circle : Icons.hourglass_bottom,
                        color: allMembersPaid ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.paymentStatusThisMonthTitle,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.paidCountOfTotal(paidCount, totalCount),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (unpaidIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          l10n.allMembersPaidThisMonth,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _UnpaidMembersList(
                          unpaidIds: unpaidIds,
                          l10n: l10n,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(item: payAction),
            const SizedBox(height: 12),
            _ActionCard(item: drawAction),
            if (isCreator) ...[
              const SizedBox(height: 12),
              _ActionCard(item: joinRequestsAction),
            ],
          ],
        );
      },
    );

  }


  /// ================= ROW =================

  Widget _row(String a, String b) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(a),

          Text(b),

        ],

      ),

    );

  }

  
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = item.enabled ? item.color : Colors.black.withAlpha(76);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.enabled ? item.onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: effectiveColor.withAlpha(35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: effectiveColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnpaidMembersList extends StatelessWidget {
  const _UnpaidMembersList({required this.unpaidIds, required this.l10n});

  final List<String> unpaidIds;
  final AppLocalizations l10n;

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final ids = unpaidIds.where((e) => e.isNotEmpty).toList();
    if (ids.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, (i + 10) > ids.length ? ids.length : (i + 10));
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        results.add(doc.data());
      }
    }

    results.sort((a, b) {
      final aName = (a['name'] ?? a['email'] ?? '').toString();
      final bName = (b['name'] ?? b['email'] ?? '').toString();
      return aName.compareTo(bName);
    });

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUsers(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.loadingUnpaidMembers,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }

        final users = snap.data!;
        final resolvedIds = users
            .map((e) => (e['uid'] ?? '').toString())
            .where((e) => e.isNotEmpty)
            .toSet();
        final unresolvedCount = unpaidIds.where((e) => !resolvedIds.contains(e)).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.unpaidMembersTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...users.take(8).map((u) {
              final name = (u['name'] ?? u['email'] ?? l10n.userGeneric).toString();
              final email = (u['email'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email.isEmpty ? name : '$name ($email)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (users.length > 8)
              Text(
                l10n.plusOthers(users.length - 8),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            if (unresolvedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.unresolvedMembersCount(unresolvedCount),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

