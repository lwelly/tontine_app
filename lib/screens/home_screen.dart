import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/invitation_service.dart';
import 'settings_screen.dart';
import 'group_detail_screen.dart';
import 'notifications_screen.dart';
import 'my_payments_screen.dart';
import 'create_group_screen.dart';
 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _MyGroupsPage extends StatelessWidget {
  const _MyGroupsPage();

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
                    icon: Icon(
                      textDirection == TextDirection.rtl
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.myGroups,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _MyGroupsTab(groupService: GroupService()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGroupsPage extends StatelessWidget {
  const _AllGroupsPage();

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
                    icon: Icon(
                      textDirection == TextDirection.rtl
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.all,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _AllGroupsTab(groupService: GroupService()),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestsPage extends StatelessWidget {
  const _JoinRequestsPage();

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
                    icon: Icon(
                      textDirection == TextDirection.rtl
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.requests,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _JoinRequestsTab(groupService: GroupService()),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.isLoading,
    required this.stats,
    required this.onNavigate,
  });

  final bool isLoading;
  final Map<String, dynamic> stats;
  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return const _DashboardSkeleton();
    }

    final totalPaid = (stats['totalPaid'] ?? 0).toString();
    final totalGroups = (stats['totalGroups'] ?? 0).toString();
    final otherGroups = (stats['publicGroups'] ?? 0).toString();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.dashboardTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            final spacing = 10.0;
            final w = (c.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: w,
                  child: _StatCard(
                    title: l10n.totalPaid,
                    value: '$totalPaid MRU',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: _StatCard(
                    title: l10n.myGroups,
                    value: totalGroups,
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: _StatCard(
                    title: l10n.otherGroups,
                    value: otherGroups,
                    icon: Icons.public_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: (userId == null)
                      ? _ModernCard(
                          leadingIcon: Icons.payments_rounded,
                          title: l10n.latestPayment,
                          subtitle: l10n.loginToSeeLatestPayment,
                          trailing: SizedBox.shrink(),
                          onTap: null,
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('payments')
                              .where('userId', isEqualTo: userId)
                              .limit(25)
                              .snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return _ModernCard(
                                leadingIcon: Icons.payments_rounded,
                                title: l10n.latestPayment,
                                subtitle: l10n.loading,
                                trailing: SizedBox.shrink(),
                                onTap: null,
                              );
                            }

                            final docs = snap.data!.docs;
                            if (docs.isEmpty) {
                              return _ModernCard(
                                leadingIcon: Icons.payments_rounded,
                                title: l10n.latestPayment,
                                subtitle: l10n.noPaymentsYet,
                                trailing: SizedBox.shrink(),
                                onTap: null,
                              );
                            }

                            QueryDocumentSnapshot? latestDoc;
                            DateTime? latestAt;

                            DateTime? resolvePaidAt(Map<String, dynamic> data) {
                              final v = data['paidAt'];
                              if (v is Timestamp) return v.toDate();
                              if (v is DateTime) return v;
                              if (v is String) return DateTime.tryParse(v);
                              return null;
                            }

                            for (final d in docs) {
                              final data = d.data() as Map<String, dynamic>;
                              final dt = resolvePaidAt(data);
                              if (dt == null) continue;
                              if (latestAt == null || dt.isAfter(latestAt)) {
                                latestAt = dt;
                                latestDoc = d;
                              }
                            }

                            if (latestDoc == null) {
                              return _ModernCard(
                                leadingIcon: Icons.payments_rounded,
                                title: l10n.latestPayment,
                                subtitle: l10n.notEnoughData,
                                trailing: SizedBox.shrink(),
                                onTap: null,
                              );
                            }

                            final data = latestDoc.data() as Map<String, dynamic>;

                            final rawAmount = data['amount'];
                            final amount = (rawAmount is num)
                                ? rawAmount.toStringAsFixed(0)
                                : rawAmount?.toString() ?? '';

                            final groupId = (data['groupId'] ?? '').toString();
                            final localName =
                                (data['groupName'] ?? data['name'] ?? '').toString();
                            final month = (data['month'] ?? '').toString();
                            final year = (data['year'] ?? '').toString();

                            final monthText = (month.isNotEmpty && year.isNotEmpty)
                                ? '$month/$year'
                                : (month.isNotEmpty ? month : '');

                            final subtitleParts = <String>[
                              if (amount.isNotEmpty) '$amount MRU',
                              if (monthText.isNotEmpty) monthText,
                            ];

                            final subtitle = subtitleParts.isEmpty
                              ? ' '
                              : subtitleParts.join(' • ');

                          return FutureBuilder<DocumentSnapshot>(
                            future: groupId.isEmpty
                                ? null
                                : FirebaseFirestore.instance
                                    .collection('groups')
                                    .doc(groupId)
                                    .get(),
                            builder: (context, gSnap) {
                              String resolvedName = localName;
                              if (gSnap.hasData && gSnap.data!.exists) {
                                final gData =
                                    gSnap.data!.data() as Map<String, dynamic>?;
                                resolvedName =
                                    (gData?['name'] ?? gData?['groupName'] ?? localName)
                                        .toString();
                              }

                              return _ModernCard(
                                leadingIcon: Icons.payments_rounded,
                                title: resolvedName.trim().isEmpty
                                    ? 'آخر دفعة'
                                    : resolvedName,
                                subtitle: subtitle,
                                trailing: const SizedBox.shrink(),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyPaymentsScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final spacing = 12.0;
            final w = (c.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: w,
                  child: _HomeNavTile(
                    title: l10n.myGroups,
                    icon: Icons.groups_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _MyGroupsPage(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: w,
                  child: _HomeNavTile(
                    title: l10n.all,
                    icon: Icons.public_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _AllGroupsPage(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: w,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('invitations')
                        .where(
                          'groupCreatorId',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .where('status', isEqualTo: 'pending')
                        .limit(1)
                        .snapshots(),
                    builder: (context, snap) {
                      final hasPending =
                          snap.hasData && snap.data!.docs.isNotEmpty;

                      return _HomeNavTile(
                        title: l10n.requests,
                        icon: Icons.person_add_rounded,
                        showRedDot: hasPending,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const _JoinRequestsPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: w,
                  child: _HomeNavTile(
                    title: l10n.latestPayment,
                    icon: Icons.payments_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyPaymentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HomeNavTile extends StatelessWidget {
  const _HomeNavTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.showRedDot = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showRedDot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 132,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withAlpha(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(icon, size: 30),
                    ),
                    if (showRedDot)
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
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
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black.withAlpha(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'لوحة التحكم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            final spacing = 10.0;
            final w = (c.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: w,
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black.withAlpha(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 16,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();
  int _selectedIndex = 0;
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await _groupService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    final pages = <Widget>[
      const SizedBox.shrink(),
      CreateGroupScreen(
        onExit: () => setState(() => _selectedIndex = 0),
      ),
      SettingsScreen(
        onExit: () => setState(() => _selectedIndex = 0),
      ),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selectedIndex == 0
                    ? CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.welcome,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: (user?.uid == null)
                                                ? null
                                                : FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(user!.uid)
                                                    .snapshots(),
                                            builder: (context, snap) {
                                              String name =
                                                  user?.displayName ??
                                                      user?.email ??
                                                      'المستخدم';

                                              if (snap.hasData && snap.data!.exists) {
                                                final u = snap.data!.data()
                                                    as Map<String, dynamic>?;
                                                name = (u?['name'] ??
                                                        u?['displayName'] ??
                                                        u?['email'] ??
                                                        name)
                                                    .toString();
                                              }

                                              return Text(
                                                name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationsScreen(),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.minTouchTarget / 2,
                                        ),
                                        child: SizedBox(
                                          width: AppSpacing.minTouchTarget,
                                          height: AppSpacing.minTouchTarget,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Center(
                                                child: Icon(
                                                  Icons.notifications_none_rounded,
                                                  color: Colors.grey.shade600,
                                                  size: 24,
                                                ),
                                              ),
                                              StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection('notifications')
                                                    .where(
                                                      'userId',
                                                      isEqualTo: FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid,
                                                    )
                                                    .where('isRead', isEqualTo: false)
                                                    .limit(1)
                                                    .snapshots(),
                                                builder: (context, snap) {
                                                  if (!snap.hasData ||
                                                      snap.data!.docs.isEmpty) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Positioned(
                                                    top: 10,
                                                    right: 12,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SettingsScreen(),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.minTouchTarget / 2,
                                        ),
                                        child: SizedBox(
                                          width: AppSpacing.minTouchTarget,
                                          height: AppSpacing.minTouchTarget,
                                          child: Icon(
                                            Icons.settings_rounded,
                                            color: Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _authService.logout(),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.minTouchTarget / 2,
                                        ),
                                        child: SizedBox(
                                          width: AppSpacing.minTouchTarget,
                                          height: AppSpacing.minTouchTarget,
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color: Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  l10n.homeTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.homeSubtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _HomeDashboard(
                                  isLoading: _isLoading,
                                  stats: _dashboardStats,
                                  onNavigate: (i) =>
                                      setState(() => _selectedIndex = i),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(height: MediaQuery.of(context).padding.bottom),
                              ],
                            ),
                          ),
                        ],
                      )
                    : pages[_selectedIndex],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: l10n.navHome,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline_rounded),
                label: l10n.navCreateGroup,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: l10n.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyGroupsTab extends StatelessWidget {
  const _MyGroupsTab({required this.groupService});
  final GroupService groupService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: groupService.myGroups(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snap.data!.docs.isEmpty) {
          return _EmptyState(
            icon: Icons.groups_rounded,
            title: l10n.noGroups,
            subtitle: l10n.noGroupsMySubtitle,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: snap.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = snap.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? l10n.groupGeneric).toString();
            final members = (data['members'] as List?)?.length ?? 0;
            final monthlyAmount = (data['monthlyAmount'] is num)
                ? (data['monthlyAmount'] as num).toInt()
                : int.tryParse((data['monthlyAmount'] ?? '').toString()) ?? 0;
            return _ModernCard(
              leadingIcon: Icons.groups_rounded,
              title: name,
              subtitle: l10n.membersCount(members),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailScreen(
                      groupId: doc.id,
                      monthlyAmount: monthlyAmount,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TotalPaidDetails extends StatefulWidget {
  const _TotalPaidDetails({required this.docs, required this.groupNameMap});

  final List<QueryDocumentSnapshot> docs;
  final Map<String, String> groupNameMap;

  @override
  State<_TotalPaidDetails> createState() => _TotalPaidDetailsState();
}

class _TotalPaidDetailsState extends State<_TotalPaidDetails> {
  String _selectedGroupId = 'all';

  @override
  void didUpdateWidget(covariant _TotalPaidDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedGroupId != 'all') {
      final exists = widget.docs.any((d) {
        final data = d.data() as Map<String, dynamic>;
        return (data['groupId'] ?? '').toString() == _selectedGroupId;
      });
      if (!exists) {
        _selectedGroupId = 'all';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalsByGroup = <String, int>{};
    for (final doc in widget.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final gid = (data['groupId'] ?? '').toString();
      if (gid.isEmpty) continue;
      final rawAmount = data['amount'];
      final amount = (rawAmount is num)
          ? rawAmount.toInt()
          : int.tryParse(rawAmount?.toString() ?? '') ?? 0;
      totalsByGroup[gid] = (totalsByGroup[gid] ?? 0) + amount;
    }

    final groupIds = totalsByGroup.keys.toList();
    groupIds.sort((a, b) {
      final aName = (widget.groupNameMap[a] ?? l10n.groupGeneric).toString();
      final bName = (widget.groupNameMap[b] ?? l10n.groupGeneric).toString();
      return aName.compareTo(bName);
    });

    final filteredDocs = (_selectedGroupId == 'all')
        ? widget.docs
        : widget.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return (data['groupId'] ?? '').toString() == _selectedGroupId;
          }).toList();

    final selectedTotal = (_selectedGroupId == 'all')
        ? totalsByGroup.values.fold<int>(0, (a, b) => a + b)
        : (totalsByGroup[_selectedGroupId] ?? 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withAlpha(10)),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedGroupId,
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(l10n.allGroups),
                      ),
                      ...groupIds.map((gid) {
                        final name = (widget.groupNameMap[gid] ?? l10n.groupGeneric).toString();
                        final total = totalsByGroup[gid] ?? 0;
                        return DropdownMenuItem(
                          value: gid,
                          child: Text('$name — $total MRU'),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedGroupId = v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ModernCard(
          leadingIcon: Icons.summarize_rounded,
          title: l10n.totalPaymentsFiltered,
          subtitle: '$selectedTotal MRU',
          trailing: const SizedBox.shrink(),
          onTap: () {},
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: filteredDocs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = filteredDocs[i].data() as Map<String, dynamic>;
              final groupId = (data['groupId'] ?? '').toString();
              final rawAmount = data['amount'];
              final amount = (rawAmount is num)
                  ? rawAmount.toInt().toString()
                  : (rawAmount ?? 0).toString();
              final month = (data['month'] ?? '').toString();
              final ts = data['timestamp'];
              String dateText = '';
              if (ts is Timestamp) {
                final d = ts.toDate();
                dateText =
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              }

              final groupName = (widget.groupNameMap[groupId] ??
                      (data['groupName'] ?? l10n.groupGeneric))
                  .toString();

              final subtitle = [
                if (month.isNotEmpty) '${l10n.monthLabel}: $month',
                if (dateText.isNotEmpty) '${l10n.dateLabel}: $dateText',
              ].join(' • ');

              return _ModernCard(
                leadingIcon: Icons.payments_rounded,
                title: groupName,
                subtitle: subtitle.isEmpty ? ' ' : subtitle,
                trailing: Text(
                  '$amount MRU',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JoinRequestsTab extends StatelessWidget {
  const _JoinRequestsTab({required this.groupService});
  final GroupService groupService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final invitationService = InvitationService();

    if (currentUserId == null) {
      return _EmptyState(
        icon: Icons.person_add_rounded,
        title: l10n.noData,
        subtitle: l10n.loginToSeeJoinRequests,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invitations')
          .where('groupCreatorId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snap.data!.docs.isEmpty) {
          return _EmptyState(
            icon: Icons.person_add_rounded,
            title: l10n.noJoinRequests,
            subtitle: l10n.joinRequestsWillAppearHere,
          );
        }

        final docs = snap.data!.docs;

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>?;
          final bData = b.data() as Map<String, dynamic>?;
          final aTs = aData?['requestedAt'] as Timestamp?;
          final bTs = bData?['requestedAt'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });

        final Map<String, List<QueryDocumentSnapshot>> byGroup = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final gid = (data['groupId'] ?? '').toString();
          if (gid.isEmpty) continue;
          (byGroup[gid] ??= []).add(d);
        }

        final groupEntries = byGroup.entries.toList();
        groupEntries.sort((a, b) {
          final aName = ((a.value.first.data() as Map<String, dynamic>)['groupName'] ?? l10n.groupGeneric).toString();
          final bName = ((b.value.first.data() as Map<String, dynamic>)['groupName'] ?? l10n.groupGeneric).toString();
          return aName.compareTo(bName);
        });

        final latest = docs.take(5).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Text(
              l10n.byGroup,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 10),
            ...groupEntries.map((e) {
              final first = e.value.first.data() as Map<String, dynamic>;
              final groupName = (first['groupName'] ?? l10n.groupGeneric).toString();
              final count = e.value.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ModernCard(
                  leadingIcon: Icons.groups_rounded,
                  title: groupName,
                  subtitle: l10n.pendingRequestsCount(count),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.featureNotAvailableYet)),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 6),
            Text(
              l10n.latestRequests,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 10),
            ...latest.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final groupId = (data['groupId'] ?? '').toString();
              final groupName = (data['groupName'] ?? l10n.groupGeneric).toString();
              final requesterId = (data['userId'] ?? '').toString();
              final requestedAt = data['requestedAt'] as Timestamp?;
              final date = requestedAt?.toDate();
              final dateText = date == null
                  ? ''
                  : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

              return Card(
                elevation: 2,
                shadowColor: Colors.black.withAlpha(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(31),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  groupName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                if (dateText.isNotEmpty)
                                  Text(
                                    '${l10n.requestDateLabel}: $dateText',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.featureNotAvailableYet)),
                              );
                            },
                            icon: const Icon(Icons.open_in_new_rounded),
                            tooltip: l10n.openGroupRequestsTooltip,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(requesterId)
                            .get(),
                        builder: (context, userSnap) {
                          String userName = 'مستخدم';
                          String userEmail = '';
                          if (userSnap.hasData && userSnap.data!.exists) {
                            final u = userSnap.data!.data() as Map<String, dynamic>?;
                            userName = (u?['name'] ?? u?['email'] ?? 'مستخدم').toString();
                            userEmail = (u?['email'] ?? '').toString();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (userEmail.isNotEmpty)
                                Text(
                                  userEmail,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await invitationService.approveRequest(doc.id, groupId, requesterId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.requestApproved),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${l10n.error}: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.check_circle_rounded, size: 18),
                              label: Text(l10n.accept),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await invitationService.rejectRequest(doc.id, groupId, requesterId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.requestRejected),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${l10n.error}: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.cancel_rounded, size: 18),
                              label: Text(l10n.reject),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _AllGroupsTab extends StatelessWidget {
  const _AllGroupsTab({required this.groupService});
  final GroupService groupService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: groupService.allPublicGroups(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snap.data!.docs.isEmpty) {
          return _EmptyState(
            icon: Icons.public_rounded,
            title: l10n.noGroups,
            subtitle: l10n.noGroupsPublicSubtitle,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: snap.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = snap.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? 'مجموعة').toString();
            final members = (data['members'] as List?)?.length ?? 0;
            final creatorId = (data['creatorId'] ?? '').toString();
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            final isCreator = currentUserId != null && creatorId == currentUserId;
            final isMember = currentUserId != null && (data['members'] as List?)?.contains(currentUserId) == true;
            final monthlyAmount = (data['monthlyAmount'] is num)
                ? (data['monthlyAmount'] as num).toInt()
                : int.tryParse((data['monthlyAmount'] ?? '').toString()) ?? 0;
            return _ModernCard(
              leadingIcon: Icons.public_rounded,
              title: name,
              subtitle: l10n.membersCount(members),
              trailing: ElevatedButton(
                onPressed: (isCreator || isMember)
                    ? null
                    : () async {
                        try {
                          await groupService.joinGroup(doc.id);
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
                              content: Text(e.toString().replaceFirst('Exception: ', '')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isCreator
                      ? l10n.myGroupBadge
                      : (isMember ? l10n.memberBadge : l10n.joinBadge),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailScreen(
                      groupId: doc.id,
                      monthlyAmount: monthlyAmount,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ModernCard extends StatelessWidget {
  const _ModernCard({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withAlpha(28)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leadingIcon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
