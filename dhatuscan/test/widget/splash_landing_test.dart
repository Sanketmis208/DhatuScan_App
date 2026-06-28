// Widget tests — Splash routing and Landing navigation
//
// Tests:
//   SplashScreen: isLoggedIn = true  → pushReplacementNamed('/dashboard')
//   SplashScreen: isLoggedIn = false → pushReplacementNamed('/landing')
//   LandingScreen: displays Sign Up and Log In buttons

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:dhatuscan/core/constants/app_routes.dart';
import 'package:dhatuscan/screens/landing/landing_screen.dart';
import 'package:dhatuscan/screens/splash/splash_screen.dart';
import 'package:dhatuscan/services/local_storage_service.dart';
import 'package:dhatuscan/providers/auth_provider.dart';
import 'package:dhatuscan/services/auth_service_interface.dart';
import 'package:dhatuscan/services/api_service_interface.dart';

// ── Test Fakes ────────────────────────────────────────────────────────────────

class MockAuthService extends Fake implements AuthServiceInterface {
  @override
  Future<String?> signInWithGoogle() async => 'fake-idtoken';
  
  @override
  Future<void> signOut() async {}

  @override
  String? get googleId => 'fake-google-id';
}

class MockApiService extends Fake implements ApiServiceInterface {
  @override
  Future<Map<String, dynamic>> login(String idToken) async {
    return {
      'token': 'fake-token',
      'userId': 'fake-user-id',
      'isNewUser': false,
      'user': {'email': 'test@example.com', 'isProfileComplete': true},
    };
  }

  @override
  Future<Map<String, dynamic>> signUp(String idToken) async {
    return {
      'token': 'fake-token',
      'userId': 'fake-user-id',
      'isNewUser': true,
      'user': {'email': 'test@example.com', 'isProfileComplete': false},
    };
  }
}

// ── Test helpers ──────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {String? currentRoute, AuthProvider? authProvider}) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider ?? AuthProvider.withServices(
      authService: MockAuthService(),
      apiService: MockApiService(),
    ),
    child: MaterialApp(
      initialRoute: currentRoute ?? AppRoutes.splash,
      routes: {
        AppRoutes.splash:          (_) => child,
        AppRoutes.landing:         (_) => const Scaffold(body: Text('landing')),
        AppRoutes.dashboard:       (_) => const Scaffold(body: Text('dashboard')),
        AppRoutes.personalDetails: (_) => const Scaffold(body: Text('personalDetails')),
      },
      onUnknownRoute: (s) =>
          MaterialPageRoute(builder: (_) => const Scaffold(body: Text('?'))),
    ),
  );
}

Future<void> _initPrefs({required bool isLoggedIn, Map<String, dynamic>? userData}) async {
  SharedPreferences.setMockInitialValues({
    'isLoggedIn': isLoggedIn,
    if (userData != null) 'userData': jsonEncode(userData),
  });
  await LocalStorageService.init();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── SplashScreen ────────────────────────────────────────────────────────────
  group('SplashScreen routing', () {
    testWidgets('isLoggedIn=true → navigates to /dashboard', (tester) async {
      await _initPrefs(isLoggedIn: true, userData: {'isProfileComplete': true, 'name': 'Arjun'});

      await tester.pumpWidget(_wrap(const SplashScreen()));
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

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
    testWidgets('displays Sign Up and Log In buttons', (tester) async {
      await _initPrefs(isLoggedIn: false);

      final authProvider = AuthProvider.withServices(
        authService: MockAuthService(),
        apiService: MockApiService(),
      );

      await tester.pumpWidget(_wrap(const LandingScreen(), authProvider: authProvider));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('signUpButton')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });
  });
}
