import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';
import '../services/group_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final String groupId;
  final int monthlyAmount;

  const PaymentScreen({
    super.key,
    required this.groupId,
    required this.monthlyAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _service = PaymentService();
  final GroupService _groupService = GroupService();
  bool _isProcessing = false;
  bool _isMember = false;
  bool _isLoading = true;
  bool _hasPaidThisMonth = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final isMember = await _groupService.isUserMember(widget.groupId);
      final hasPaid = isMember
          ? await _service.hasUserPaidThisMonth(widget.groupId)
          : false;
      if (mounted) {
        setState(() {
          _isMember = isMember;
          _hasPaidThisMonth = hasPaid;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMember = false;
          _hasPaidThisMonth = false;
          _isLoading = false;
        });
      }
    }
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
        title: Text(l10n.paymentTitle),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_isMember
                ? _buildNotMemberWidget(context)
                : _buildPaymentForm(context, l10n),
      ),
    );
  }

  Widget _buildNotMemberWidget(BuildContext context) {
    final textDirection = Directionality.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.mustBeMemberToPayTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mustJoinGroupFirstSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(textDirection == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back),
            label: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, AppLocalizations l10n) {
    final textDirection = Directionality.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.paymentNotification,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.amountDueLabel}: ${widget.monthlyAmount} MRU',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_hasPaidThisMonth)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success.withAlpha(102),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.success, size: 28),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    l10n.alreadyPaidThisMonth,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _isProcessing
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() => _isProcessing = true);
                                    try {
                                      await _service.pay(
                                        groupId: widget.groupId,
                                        amount: widget.monthlyAmount,
                                      );
                                      if (mounted) {
                                        setState(() =>
                                            _hasPaidThisMonth = true);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle,
                                                    color: Colors.white),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    l10n.paymentSuccessWithNotification,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: AppColors.success,
                                            duration: const Duration(
                                                seconds: 3),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.paymentError(
                                              e.toString().replaceAll('Exception: ', ''),
                                            ),
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isProcessing = false);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.payment),
                                  label: Text(l10n.payButton),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.liveStatusUpdate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _service.paymentsByGroup(widget.groupId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.paymentsEmptyTitle,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final date = timestamp?.toDate();
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.success.withAlpha(51),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                ),
                              ),
                              title: Text(
                                '${l10n.amountLabel}: ${data['amount']} MRU',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: textDirection == TextDirection.rtl
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text('${l10n.monthLabelShort}: ${data['month'] ?? l10n.noData}'),
                                  if (date != null)
                                    Text(
                                      '${l10n.dateLabelShort}: ${date.day}/${date.month}/${date.year}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.paidBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
        ],
      ),
    );
  }
}
