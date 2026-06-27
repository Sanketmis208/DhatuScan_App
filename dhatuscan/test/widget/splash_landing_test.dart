// Widget tests — Splash routing and Landing navigation
// Validates: Tasks 5.2 and 5.3
//
// Tests:
//   SplashScreen: isLoggedIn = true  → pushReplacementNamed('/dashboard')
//   SplashScreen: isLoggedIn = false → pushReplacementNamed('/landing')
//   LandingScreen: tap "Begin Assessment" → pushNamed('/phone')

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhatuscan/core/constants/app_routes.dart';
import 'package:dhatuscan/screens/landing/landing_screen.dart';
import 'package:dhatuscan/screens/splash/splash_screen.dart';
import 'package:dhatuscan/services/local_storage_service.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Wraps [child] in a [MaterialApp] that records push/replacement calls and
/// serves a stub route for every named route so navigation never throws.
Widget _wrap(Widget child, {String? currentRoute}) {
  return MaterialApp(
    initialRoute: currentRoute ?? AppRoutes.splash,
    routes: {
      AppRoutes.splash:          (_) => child,
      AppRoutes.landing:         (_) => const Scaffold(body: Text('landing')),
      AppRoutes.phone:           (_) => const Scaffold(body: Text('phone')),
      AppRoutes.dashboard:       (_) => const Scaffold(body: Text('dashboard')),
      AppRoutes.personalDetails: (_) => const Scaffold(body: Text('personalDetails')),
    },
    onUnknownRoute: (s) =>
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('?'))),
  );
}

/// Initialises SharedPreferences with [isLoggedIn] before building the widget.
Future<void> _initPrefs({required bool isLoggedIn, Map<String, dynamic>? userData}) async {
  SharedPreferences.setMockInitialValues({
    'isLoggedIn': isLoggedIn,
    if (userData != null) 'userData': jsonEncode(userData),
  });
  await LocalStorageService.init();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // Reset SharedPreferences between tests.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── SplashScreen ────────────────────────────────────────────────────────────
  group('SplashScreen routing', () {
    testWidgets('isLoggedIn=true → navigates to /dashboard', (tester) async {
      await _initPrefs(isLoggedIn: true, userData: {'isProfileComplete': true});

      await tester.pumpWidget(_wrap(const SplashScreen()));
      // Pump through the 2.5 s delay.
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      // After navigation the stub 'dashboard' screen should be visible.
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('landing'), findsNothing);
    });

    testWidgets('isLoggedIn=true, isProfileComplete=false → navigates to /profile/new', (tester) async {
      await _initPrefs(isLoggedIn: true, userData: {'isProfileComplete': false});

      await tester.pumpWidget(_wrap(const SplashScreen()));
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(find.text('personalDetails'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });

    testWidgets('isLoggedIn=false → navigates to /landing', (tester) async {
      await _initPrefs(isLoggedIn: false);

      await tester.pumpWidget(_wrap(const SplashScreen()));
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(find.text('landing'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });
  });

  // ── LandingScreen ────────────────────────────────────────────────────────────
  group('LandingScreen navigation', () {
    testWidgets('tapping "Begin Assessment →" navigates to /phone',
        (tester) async {
      await _initPrefs(isLoggedIn: false);

      await tester.pumpWidget(_wrap(const LandingScreen()));
      await tester.pumpAndSettle();

      // Find and tap the primary "Begin Assessment" button by its Key.
      final beginBtn = find.byKey(const Key('beginAssessmentButton'));
      expect(beginBtn, findsOneWidget);
      await tester.tap(beginBtn);
      await tester.pumpAndSettle();

      expect(find.text('phone'), findsOneWidget);
    });

    testWidgets('tapping "I already have an account" also navigates to /phone',
        (tester) async {
      await _initPrefs(isLoggedIn: false);

      await tester.pumpWidget(_wrap(const LandingScreen()));
      await tester.pumpAndSettle();

      final alreadyBtn =
          find.byKey(const Key('alreadyHaveAccountButton'));
      expect(alreadyBtn, findsOneWidget);
      await tester.tap(alreadyBtn);
      await tester.pumpAndSettle();

      expect(find.text('phone'), findsOneWidget);
    });
  });
}
