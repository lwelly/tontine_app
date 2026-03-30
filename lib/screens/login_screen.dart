import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;

  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';
  String name = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.savings_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TITLE
                  Text(
                    l10n.loginTitle,
                    style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.homeSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  /// CARD
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            /// EMAIL
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n.emailOrPhone,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              textAlign: TextAlign.start,
                              onChanged: (v) => email = v,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.loginEmailOrPhoneRequired;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            /// PASSWORD
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                              ),
                              textAlign: TextAlign.start,
                              obscureText: true,
                              onChanged: (v) => password = v,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.passwordMinLength;
                                }
                                return null;
                              },
                            ),

                            if (!_isLogin) ...[
                              const SizedBox(height: 16),

                              /// NAME
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: l10n.fullNameLabel,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                textAlign: TextAlign.start,
                                onChanged: (v) => name = v,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.fullNameRequired;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              /// PHONE
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: l10n.phoneLabel,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.phone),
                                ),
                                textAlign: TextAlign.start,
                                onChanged: (v) => phone = v,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.phoneRequired;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              /// CONFIRM PASSWORD
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: l10n.confirmPasswordLabel,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                textAlign: TextAlign.start,
                                obscureText: true,
                                onChanged: (v) => confirmPassword = v,
                                validator: (value) {
                                  if (value != password) {
                                    return l10n.passwordsDoNotMatch;
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 32),

                            /// BUTTON
                            _isLoading
                                ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                                : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isLogin
                                      ? l10n.login
                                      : l10n.createAccount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: () {
                                setState(() => _isLogin = !_isLogin);
                              },
                              child: Text(
                                _isLogin
                                    ? l10n.createAccount
                                    : l10n.login,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              l10n.allUsersEqual,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: Colors.grey.shade600,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.login(email: email, password: password);
      } else {
        await _auth.register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );

        if (!mounted) return;
        setState(() => _isLogin = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final l10n = AppLocalizations.of(context);
          if (l10n == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.registrationSuccessTitle}. ${l10n.registrationVerifyEmailAndLogin}',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = _getErrorMessage(e);
      final isNetworkError = _isNetworkOrRecaptchaError(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isNetworkError ? 5 : 3),
          action: isNetworkError
              ? SnackBarAction(
                  label: AppLocalizations.of(context)!.retry,
                  textColor: Colors.white,
                  onPressed: () => _submit(),
                )
              : null,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  bool _isNetworkOrRecaptchaError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('recaptcha') ||
        msg.contains('timeout') ||
        msg.contains('unreachable') ||
        msg.contains('connection');
  }

  String _getErrorMessage(Object e) {
    final l10n = AppLocalizations.of(context)!;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return l10n.authInvalidEmail;
        case 'user-disabled':
          return l10n.authUserDisabled;
        case 'user-not-found':
          return l10n.authUserNotFound;
        case 'wrong-password':
          return l10n.authWrongPassword;
        case 'email-already-in-use':
          return l10n.authEmailAlreadyInUse;
        case 'weak-password':
          return l10n.authWeakPassword;
        case 'network-request-failed':
        case 'too-many-requests':
          return l10n.authNetworkError;
      }
      if (e.message != null &&
          (e.message!.contains('network') ||
              e.message!.contains('timeout') ||
              e.message!.contains('recaptcha'))) {
        return l10n.authNetworkError;
      }
    }
    final msg = e.toString();
    if (msg.contains('network') ||
        msg.contains('timeout') ||
        msg.contains('recaptcha') ||
        msg.contains('unreachable')) {
      return l10n.authNetworkError;
    }
    return '${l10n.error}: ${e.toString().replaceAll('Exception:', '').trim()}';
  }
}
