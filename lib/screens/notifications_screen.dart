import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(textDirection == TextDirection.rtl
                        ? Icons.arrow_forward
                        : Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.notificationsTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded),
                    onPressed: () async {
                      try {
                        await _markAllAsRead();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.unableToMarkAllAsRead),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    tooltip: l10n.markAllAsRead,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.failedToLoadNotifications,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noNotifications,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.sentToAll,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notifications = snapshot.data!.docs;

                  notifications.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>?;
                    final bData = b.data() as Map<String, dynamic>?;
                    final aTimestamp = aData?['timestamp'] as Timestamp?;
                    final bTimestamp = bData?['timestamp'] as Timestamp?;
                    if (aTimestamp == null && bTimestamp == null) return 0;
                    if (aTimestamp == null) return 1;
                    if (bTimestamp == null) return -1;
                    return bTimestamp.compareTo(aTimestamp);
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notifications[index].data() as Map<String, dynamic>;
                      final timestamp = notification['timestamp'] as Timestamp?;
                      final date = timestamp?.toDate();
                      final type = notification['type'] ?? 'general';
                      final isRead = notification['isRead'] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isRead ? 1 : 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isRead
                              ? BorderSide.none
                              : BorderSide(
                                  color: AppColors.primaryDark,
                                  width: 2,
                                ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                backgroundColor: _getNotificationColor(type),
                                child: Icon(
                                  _getNotificationIcon(type),
                                  color: Colors.white,
                                ),
                              ),
                              if (!isRead)
                                Positioned(
                                  top: -6,
                                  left: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            _getNotificationTitle(type, l10n),
                            style: TextStyle(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getNotificationMessage(notification, type, l10n),
                                style: TextStyle(
                                  color: isRead
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                ),
                              ),
                              // Special formatting for payment confirmations
                              if (type == 'payment_confirmation' &&
                                  notification['amount'] != null &&
                                  notification['groupName'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        color: AppColors.primaryDark,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${notification['amount']} MRU • ${notification['groupName']}',
                                        style: TextStyle(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 4),
                              if (date != null)
                                Text(
                                  _formatDate(date, l10n),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: !isRead
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () {
                            if (!isRead) {
                              FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(notifications[index].id)
                                  .update({'isRead': true});
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'payment_confirmation':
        return Colors.green;
      case 'payment_due':
        return Colors.orange;
      case 'beneficiary':
        return Colors.blue;
      case 'payment_delay':
        return Colors.red;
      case 'new_member':
        return Colors.purple;
      case 'member_left':
        return Colors.amber;
      case 'join_request':
        return Colors.indigo;
      case 'join_approved':
        return Colors.teal;
      case 'join_rejected':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'payment_confirmation':
        return Icons.check_circle;
      case 'payment_due':
        return Icons.payment;
      case 'beneficiary':
        return Icons.emoji_events;
      case 'payment_delay':
        return Icons.warning;
      case 'new_member':
        return Icons.person_add;
      case 'member_left':
        return Icons.person_remove;
      case 'join_request':
        return Icons.person_add_disabled;
      case 'join_approved':
        return Icons.how_to_reg;
      case 'join_rejected':
        return Icons.person_off;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String type, AppLocalizations l10n) {
    switch (type) {
      case 'payment_confirmation':
        return l10n.paymentConfirmationTitle;
      case 'payment_due':
        return l10n.paymentDue;
      case 'beneficiary':
        return l10n.beneficiaryAnnouncement;
      case 'payment_delay':
        return l10n.paymentDelay;
      case 'new_member':
        return l10n.newMemberTitle;
      case 'member_left':
        return l10n.memberLeftTitle;
      case 'join_request':
        return l10n.joinRequestTitle;
      case 'join_approved':
        return l10n.joinApprovedTitle;
      case 'join_rejected':
        return l10n.joinRejectedTitle;
      default:
        return l10n.notificationGeneric;
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return l10n.now;
        }
        return l10n.minutesAgo(difference.inMinutes);
      }
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getNotificationMessage(
    Map<String, dynamic> notification,
    String type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case 'payment_confirmation':
        final amount = notification['amount'];
        final month = notification['month'];
        final groupName = notification['groupName'];
        if (amount != null && month != null && groupName != null) {
          return l10n.paymentConfirmationMessage(
            amount.toString(),
            groupName.toString(),
            month.toString(),
          );
        }
        break;
      case 'join_approved':
        return l10n.joinApprovedMessage;
      case 'join_rejected':
        return l10n.joinRejectedMessage;
      case 'join_request':
        return l10n.joinRequestMessage;
      case 'member_left':
        return l10n.memberLeftMessage;
    }

    final legacyMessage = notification['message'];
    if (legacyMessage != null) {
      return legacyMessage.toString();
    }
    return l10n.notificationGeneric;
  }
}
