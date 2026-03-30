import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tontine_app/main.dart';
import 'package:tontine_app/services/firestore_setup.dart';

void main() {
  testWidgets('Lancement de l’application Tontine', (WidgetTester tester) async {
    // Create FirestoreSetup instance
    final firestoreSetup = FirestoreSetup();
    
    // Lance l'application
    await tester.pumpWidget(
      TontineApp(
        firestoreSetup: firestoreSetup,
        initialLocale: const Locale('ar', 'SA'),
      ),
    );

    // Vérifie qu'un widget MaterialApp est présent
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
  