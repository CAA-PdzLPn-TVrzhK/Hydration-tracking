// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hydration_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('Onboarding screen shows welcome text (ru)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('ru'),
        ],
        locale: Locale('ru'),
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final welcomeText = AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!.welcome;
    expect(find.text(welcomeText), findsOneWidget);
  });

  testWidgets('Onboarding screen shows welcome text (en)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('ru'),
        ],
        locale: Locale('en'),
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final welcomeText = AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!.welcome;
    expect(find.text(welcomeText), findsOneWidget);
  });
}
