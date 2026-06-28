// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhatuscan/providers/auth_provider.dart' as app;
import 'package:dhatuscan/services/auth_service_interface.dart';
import 'package:dhatuscan/services/api_service_interface.dart';
import 'package:dhatuscan/core/utils/api_exception.dart';
import 'package:dhatuscan/services/local_storage_service.dart';

typedef AuthState = app.AuthState;

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class FakeAuthService implements AuthServiceInterface {
  bool failGoogleSignIn = false;
  String? stubbedIdToken = 'fake-google-idtoken';

  @override
  Future<String?> signInWithGoogle() async {
    if (failGoogleSignIn) {
      throw Exception('Google Sign-In failed');
    }
    return stubbedIdToken;
  }

  @override
  Future<void> signOut() async {
    await LocalStorageService.logout();
  }

  @override
  String? get googleId => 'fake-google-id';
}

class FakeApiService implements ApiServiceInterface {
  bool signupSuccess = true;
  bool loginSuccess = true;
  int signupStatusCode = 201;
  int loginStatusCode = 200;
  String signupErrorMessage = 'SignUp failed';
  String loginErrorMessage = 'Login failed';

  @override
  Future<Map<String, dynamic>> signUp(String idToken) async {
    if (!signupSuccess) {
      throw ApiException(statusCode: signupStatusCode, message: signupErrorMessage);
    }
    return {
      'token': 'fake-jwt-signup',
      'userId': 'fake-user-id-signup',
      'isNewUser': true,
      'user': {'email': 'signup@example.com', 'isProfileComplete': false},
    };
  }

  @override
  Future<Map<String, dynamic>> login(String idToken) async {
    if (!loginSuccess) {
      throw ApiException(statusCode: loginStatusCode, message: loginErrorMessage);
    }
    return {
      'token': 'fake-jwt-login',
      'userId': 'fake-user-id-login',
      'isNewUser': false,
      'user': {'email': 'login@example.com', 'isProfileComplete': true},
    };
  }

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profileData) async => {};

  @override
  Future<Map<String, dynamic>> getProfile(String userId) async => {};

  @override
  Future<Map<String, dynamic>> submitAssessment(Map<String, dynamic> assessmentData) async => {};

  @override
  Future<Map<String, dynamic>> getAssessmentHistory(String userId) async => {};

  @override
  Future<Map<String, dynamic>> getAssessment(String assessmentId) async => {};
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper — builds a provider with fresh in-memory SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

Future<app.AuthProvider> _makeProvider({
  required FakeAuthService authService,
  required FakeApiService apiService,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  LocalStorageService.initWithPrefs(prefs);

  return app.AuthProvider.withServices(
    authService: authService,
    apiService: apiService,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('AuthProvider — signUp', () {
    test('happy path: state goes initial → authenticating → authenticated', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      final states = <AuthState>[];
      provider.addListener(() => states.add(provider.state));

      expect(provider.state, AuthState.initial);

      final result = await provider.signUp();

      expect(result, isTrue);
      expect(states, contains(AuthState.authenticating));
      expect(states.last, AuthState.authenticated);
      expect(provider.isNewUser, isTrue);
      expect(provider.errorMessage, isNull);
      expect(LocalStorageService.authToken, 'fake-jwt-signup');
      expect(LocalStorageService.userId, 'fake-user-id-signup');
      expect(LocalStorageService.isLoggedIn, isTrue);
    });

    test('failure user already exists: returns false, error state, sets errorMessage', () async {
      final auth = FakeAuthService();
      final api = FakeApiService()
        ..signupSuccess = false
        ..signupStatusCode = 400
        ..signupErrorMessage = 'You already have an account. Please log in.';
      final provider = await _makeProvider(authService: auth, apiService: api);

      final result = await provider.signUp();

      expect(result, isFalse);
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, 'You already have an account. Please log in.');
    });
  });

  group('AuthProvider — login', () {
    test('happy path: logs in and saves JWT', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      final result = await provider.login();

      expect(result, isTrue);
      expect(provider.state, AuthState.authenticated);
      expect(provider.isNewUser, isFalse);
      expect(LocalStorageService.authToken, 'fake-jwt-login');
      expect(LocalStorageService.userId, 'fake-user-id-login');
    });

    test('failure account not found: returns false, error state, sets errorMessage', () async {
      final auth = FakeAuthService();
      final api = FakeApiService()
        ..loginSuccess = false
        ..loginStatusCode = 404
        ..loginErrorMessage = 'Account not found. Please sign up.';
      final provider = await _makeProvider(authService: auth, apiService: api);

      final result = await provider.login();

      expect(result, isFalse);
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, 'Account not found. Please sign up.');
    });
  });

  group('AuthProvider — signOut', () {
    test('signOut: clears credentials and local storage', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.login();
      expect(provider.isLoggedIn, isTrue);

      await provider.signOut();

      expect(provider.state, AuthState.initial);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}
