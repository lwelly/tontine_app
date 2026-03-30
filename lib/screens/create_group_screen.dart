import 'package:flutter/material.dart';
import '../services/firestore_setup.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
    this.onExit,
  });

  final VoidCallback? onExit;
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _setup = FirestoreSetup();
  String _name = '';
  int _amount = 0;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final groupId = await _setup.createGroup(
        groupName: _name,
        monthlyAmount: _amount,
        memberEmails: [],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.groupCreatedSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (widget.onExit != null) {
        widget.onExit!.call();
      } else {
        Navigator.pop(context, {
          'groupId': groupId,
          'monthlyAmount': _amount,
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () {
              if (widget.onExit != null) {
                widget.onExit!.call();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(l10n.createGroupTitle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.groupNameLabel,
                              prefixIcon: const Icon(Icons.groups_rounded),
                            ),
                            textAlign: TextAlign.start,
                            validator: (v) => v == null || v.isEmpty
                                ? l10n.fieldRequired
                                : null,
                            onChanged: (v) => _name = v,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.monthlyAmountLabel,
                              prefixIcon: const Icon(Icons.payments_rounded),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.start,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.fieldRequired;
                              if ((int.tryParse(v) ?? 0) <= 0) {
                                return l10n.enterValidAmount;
                              }
                              return null;
                            },
                            onChanged: (v) => _amount = int.tryParse(v) ?? 0,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_circle_outline_rounded),
                              label: Text(
                                _loading
                                    ? l10n.creatingGroup
                                    : l10n.createGroupAction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}