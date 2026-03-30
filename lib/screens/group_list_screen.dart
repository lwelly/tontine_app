import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/group_service.dart';
import '../services/invitation_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> with SingleTickerProviderStateMixin {
  final GroupService _service = GroupService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(textDirection == TextDirection.rtl
              ? Icons.arrow_forward
              : Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.groupsTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: l10n.myGroupsTabTitle),
            Tab(text: l10n.allGroupsTabTitle),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyGroupsList(),
            _buildAllGroupsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.createGroupFab),
      ),
    );
  }

  Widget _buildMyGroupsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.myGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Check for permission errors
        if (snapshot.hasError) {
          final l10n = AppLocalizations.of(context)!;
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
                  l10n.firestoreErrorTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.error}: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noTontineGroupsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noTontineGroupsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return _buildGroupsList(snapshot.data!.docs, isMyGroups: true);
      },
    );
  }

  Widget _buildAllGroupsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.allPublicGroups(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.public_outlined,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noAvailableGroupsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noAvailableGroupsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return _buildGroupsList(snapshot.data!.docs, isMyGroups: false);
      },
    );
  }

  Widget _buildGroupsList(List<DocumentSnapshot> docs, {required bool isMyGroups}) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);
    final chevronIcon = textDirection == TextDirection.rtl
        ? Icons.arrow_forward_ios
        : Icons.arrow_back_ios;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final group = docs[i].data() as Map<String, dynamic>;
        final groupId = docs[i].id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(38),
              child: Icon(
                Icons.groups_rounded,
              ),
            ),
            title: Text(
              (group['groupName'] ?? l10n.unnamedGroup).toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${l10n.amount}: ${int.tryParse(group['monthlyAmount']?.toString() ?? '') ?? 0} MRU',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${l10n.members}: ${group['members']?.length ?? 0}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(group['status'] ?? 'active'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(group['status'] ?? 'active'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: isMyGroups 
              ? Icon(chevronIcon)
              : FutureBuilder<bool>(
                  future: _service.isUserMember(groupId),
                  builder: (context, memberSnapshot) {
                    final isMember = memberSnapshot.data ?? false;
                    
                    if (isMember) {
                      return const Icon(Icons.check_circle, color: AppColors.success);
                    }
                    
                    return FutureBuilder<bool>(
                      future: InvitationService().hasPendingRequest(groupId),
                      builder: (context, pendingSnapshot) {
                        final hasPendingRequest = pendingSnapshot.data ?? false;
                        
                        if (hasPendingRequest) {
                          return ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(l10n.pendingRequest),
                          );
                        }
                        
                        return ElevatedButton(
                          onPressed: () async {
                            try {
                              await _service.joinGroup(groupId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.joinRequestSent),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${l10n.error}: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(l10n.joinRequestAction),
                        );
                      },
                    );
                  },
                ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(
                    groupId: groupId,
                    monthlyAmount: int.tryParse(group['monthlyAmount']?.toString() ?? '') ?? 5000,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'paused':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'active':
        return l10n.statusActive;
      case 'completed':
        return l10n.statusCompleted;
      case 'paused':
        return l10n.statusPaused;
      default:
        return l10n.statusUnknown;
    }
  }
}
