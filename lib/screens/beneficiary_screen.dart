import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/beneficiary_service.dart';
import '../services/group_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class BeneficiaryScreen extends StatefulWidget {
  final String groupId;

  const BeneficiaryScreen({super.key, required this.groupId});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen>
    with TickerProviderStateMixin {
  final BeneficiaryService _service = BeneficiaryService();
  final GroupService _groupService = GroupService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isDrawing = false;
  bool _hasDrawn = false;
  bool _isCreator = false;
  bool _isLoading = true;
  bool _allMembersPaid = false;

  int _selectedTab = 0;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await _checkMembership();
    await _checkPaymentStatus();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ================= MEMBERSHIP =================

  Future<void> _checkMembership() async {
    try {
      final doc = await _groupService.getGroupDetails(widget.groupId);

      final data = doc.data() as Map<String, dynamic>?;

      final currentUser = FirebaseAuth.instance.currentUser?.uid;

      if (data != null && data['creatorId'] == currentUser) {
        _isCreator = true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ================= PAYMENT =================

  Future<void> _checkPaymentStatus() async {
    try {
      final doc = await _groupService.getGroupDetails(widget.groupId);

      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) return;

      final members = List<String>.from(data['members'] ?? []);

      if (members.isEmpty) {
        _allMembersPaid = false;
        return;
      }

      final now = DateTime.now();

      final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final futures = members.map(
        (member) => FirebaseFirestore.instance
            .collection('payments')
            .where('groupId', isEqualTo: widget.groupId)
            .where('userId', isEqualTo: member)
            .where('month', isEqualTo: month)
            .limit(1)
            .get(),
      );

      final results = await Future.wait(futures);

      final paidCount = results.where((r) => r.docs.isNotEmpty).length;

      _allMembersPaid = paidCount == members.length;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ================= DRAW =================

  Future<void> _performDraw() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isCreator) {
      _showError(l10n.drawCreatorOnlySnackbar);
      return;
    }

    if (!_allMembersPaid) {
      _showError(l10n.drawRequiresAllPaidBeforeStart);
      return;
    }

    setState(() {
      _isDrawing = true;
    });

    try {
      await _service.performAutomaticDraw(widget.groupId);

      if (!mounted) return;

      setState(() {
        _hasDrawn = true;
      });

      _animationController.forward();

      _showSuccess(l10n.drawSuccess);
    } catch (e) {
      _showError(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _isDrawing = false;
    });
  }

  // ================= UI HELPERS =================

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ================= CURRENT WINNER =================

  Widget _currentWinner() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: _service.currentBeneficiary(widget.groupId),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noBeneficiaryYetTitle,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noBeneficiaryYetSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final data = snap.data!.docs.first.data() as Map<String, dynamic>;

        final userId = data['userId'];
        final month = data['month'] ?? '';

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _hasDrawn ? _scaleAnimation.value : 1,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade200.withAlpha(128),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.amber.shade700,
                          Colors.orange.shade600,
                          Colors.deepOrange.shade500,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.beneficiaryThisMonthTitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(242),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(userId)
                                .get(),
                            builder: (_, userSnap) {
                              if (!userSnap.hasData ||
                                  !userSnap.data!.exists) {
                                return Text(
                                  AppLocalizations.of(context)!.loading,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              final u = userSnap.data!.data() as Map<String, dynamic>?;

                              return Text(
                                (u?['name'] ?? u?['email'] ?? l10n.memberGeneric)
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(64),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${l10n.monthLabel}: $month',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(242),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= ALL WINNERS =================

  Widget _allWinners() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: _service.allMonthlyBeneficiaries(widget.groupId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap.error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snap.connectionState == ConnectionState.waiting || !snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snap.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTs = aData['createdAt'];
            final bTs = bData['createdAt'];
            final aDate = aTs is Timestamp ? aTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = bTs is Timestamp ? bTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  l10n.noWinnersYet,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final userId = d['userId'] as String?;
            final month = d['month'] as String? ?? '';
            final ts = d['createdAt'];
            final date = ts != null && ts is Timestamp
                ? ts.toDate()
                : DateTime.now();

            return FutureBuilder<DocumentSnapshot?>(
              future: userId != null
                  ? FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .get()
                  : Future.value(null),
              builder: (context, userSnap) {
                String name = l10n.userGeneric;
                if (userSnap.hasData &&
                    userSnap.data != null &&
                    (userSnap.data?.exists ?? false)) {
                  final u = userSnap.data!.data() as Map<String, dynamic>?;
                  name = (u?['name'] ?? u?['email'] ?? l10n.userGeneric).toString();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.amber.shade800,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${l10n.monthLabel}: $month • ${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.winnerBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.loading,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCreator) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 80, color: Colors.red.shade300),
                    const SizedBox(height: 24),
                    Text(
                      l10n.accessRestrictedTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.drawCreatorOnlySnackbar,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.back),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_allMembersPaid) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty_rounded,
                        size: 80, color: Colors.orange.shade300),
                    const SizedBox(height: 24),
                    Text(
                      l10n.waitingForPaymentTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.drawRequiresAllPaidSnackbar,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.back),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              if (_selectedTab == 0)
                SliverToBoxAdapter(child: _buildDrawCard()),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _selectedTab == 0 ? _currentWinner() : _allWinners(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.drawTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Colors.amber.shade600
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.currentTabTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _selectedTab == 0
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Colors.amber.shade600
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.allTabTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _selectedTab == 1
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.casino_rounded,
                size: 40,
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.automaticDrawTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.fairTurnSystemSubtitle,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDrawing ? null : _performDraw,
                  icon: _isDrawing
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  label: Text(
                    _isDrawing ? l10n.loading : l10n.startDrawAction,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}