import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_setup.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firestore setup
  final firestoreSetup = FirestoreSetup();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_locale');
  final initialLocale = (savedLang == 'fr')
      ? const Locale('fr', 'FR')
      : const Locale('ar', 'SA');
  
  runApp(
    TontineApp(
      firestoreSetup: firestoreSetup,
      initialLocale: initialLocale,
    ),
  );
}

class TontineAppLocale {
  static void Function(Locale locale)? _setter;

  static void bind(void Function(Locale locale) setter) {
    _setter = setter;
  }

  static void setLocale(Locale locale) {
    final s = _setter;
    if (s == null) return;
    s(locale);
  }
}

class TontineApp extends StatefulWidget {
  final FirestoreSetup firestoreSetup;
  final Locale initialLocale;
  
  const TontineApp({
    super.key,
    required this.firestoreSetup,
    required this.initialLocale,
  });

  @override
  State<TontineApp> createState() => _TontineAppState();
}

class _TontineAppState extends State<TontineApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    TontineAppLocale.bind((locale) {
      if (!mounted) return;
      setState(() => _locale = locale);
      SharedPreferences.getInstance().then((p) {
        p.setString('app_locale', locale.languageCode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'توتين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      home: StreamBuilder<User?>(
        stream: AuthService().authState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            widget.firestoreSetup.initializeUserDocument();
            return HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
