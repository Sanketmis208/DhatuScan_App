// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhatuscan/providers/auth_provider.dart' as app;
import 'package:dhatuscan/services/auth_service_interface.dart';
import 'package:dhatuscan/services/api_service_interface.dart';
import 'package:dhatuscan/core/utils/api_exception.dart';
import 'package:dhatuscan/services/local_storage_service.dart';

// Convenient typedef so test code stays readable.
typedef AuthState = app.AuthState;

// ─────────────────────────────────────────────────────────────────────────────
// Fakes — pure Dart, no Firebase initialisation required
// ─────────────────────────────────────────────────────────────────────────────

/// Controls what [FakeAuthService.sendOtp] does on the next call.
enum _SendOtpBehaviour { success, failure }

/// Controls what [FakeAuthService.verifyOtp] does on the next call.
enum _VerifyOtpBehaviour { success, invalidCode, expired, genericFailure }

class FakeAuthService implements AuthServiceInterface {
  _SendOtpBehaviour sendBehaviour = _SendOtpBehaviour.success;
  _VerifyOtpBehaviour verifyBehaviour = _VerifyOtpBehaviour.success;

  String stubbedVerificationId = 'fake-verification-id';
  UserCredential? stubbedCredential;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    int? resendToken,
  }) async {
    if (sendBehaviour == _SendOtpBehaviour.success) {
      onCodeSent(stubbedVerificationId, null);
    } else {
      onVerificationFailed(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error. Check your connection.',
        ),
      );
    }
  }

  @override
  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    switch (verifyBehaviour) {
      case _VerifyOtpBehaviour.success:
        return stubbedCredential ?? _FakeUserCredential();
      case _VerifyOtpBehaviour.invalidCode:
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Invalid OTP. Please check and try again.',
        );
      case _VerifyOtpBehaviour.expired:
        throw FirebaseAuthException(
          code: 'session-expired',
          message: 'OTP session expired. Please resend OTP.',
        );
      case _VerifyOtpBehaviour.genericFailure:
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'Authentication failed.',
        );
    }
  }

  @override
  Future<UserCredential?> signInWithCredential(
      PhoneAuthCredential credential) async {
    return _FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    // Mirror AuthService: clear local storage so isLoggedIn returns false
    await LocalStorageService.logout();
  }

  @override
  User? get currentUser => null;

  @override
  String? get firebaseUid => null;
}

class FakeApiService implements ApiServiceInterface {
  bool checkUserSuccess = true;
  bool isNewUser = false;
  String stubbedToken = 'fake-jwt-token';
  String stubbedUserId = 'fake-user-id';

  @override
  Future<Map<String, dynamic>> checkUser(
    String phone, {
    String? firebaseUid,
  }) async {
    if (!checkUserSuccess) {
      throw const ApiException(statusCode: 401, message: 'Unauthorized');
    }
    return {
      'token': stubbedToken,
      'userId': stubbedUserId,
      'isNewUser': isNewUser,
    };
  }

  @override
  Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> profileData) async => {};

  @override
  Future<Map<String, dynamic>> getProfile(String userId) async => {};

  @override
  Future<Map<String, dynamic>> submitAssessment(
      Map<String, dynamic> assessmentData) async => {};

  @override
  Future<Map<String, dynamic>> getAssessmentHistory(String userId) async => {};

  @override
  Future<Map<String, dynamic>> getAssessment(String assessmentId) async => {};
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimal fake UserCredential / User
// ─────────────────────────────────────────────────────────────────────────────

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'fake-uid-123';
}

class _FakeUserCredential extends Fake implements UserCredential {
  @override
  User? get user => _FakeUser();

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
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
  group('AuthProvider — sendOtp', () {
    test('happy path: state goes initial → sendingOtp → otpSent', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      final states = <AuthState>[];
      provider.addListener(() => states.add(provider.state));

      // Initial state before any call
      expect(provider.state, AuthState.initial);

      await provider.sendOtp('9876543210');

      // sendOtp fires two notifyListeners: once for sendingOtp, once for otpSent
      expect(states, contains(AuthState.sendingOtp));
      expect(states.last, AuthState.otpSent);
      expect(provider.verificationId, 'fake-verification-id');
      expect(provider.errorMessage, isNull);
    });

    test('failure: state goes initial → sendingOtp → error, errorMessage set', () async {
      final auth = FakeAuthService()..sendBehaviour = _SendOtpBehaviour.failure;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      final states = <AuthState>[];
      provider.addListener(() => states.add(provider.state));

      await provider.sendOtp('9876543210');

      expect(states, contains(AuthState.sendingOtp));
      expect(states.last, AuthState.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, isNotEmpty);
    });
  });

  group('AuthProvider — verifyOtp', () {
    test('success new user: state → authenticated, isNewUser == true', () async {
      final auth = FakeAuthService();
      final api = FakeApiService()..isNewUser = true;
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      expect(provider.state, AuthState.otpSent);

      final result = await provider.verifyOtp('123456');

      expect(result, isTrue);
      expect(provider.state, AuthState.authenticated);
      expect(provider.isNewUser, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('success returning user: state → authenticated, isNewUser == false', () async {
      final auth = FakeAuthService();
      final api = FakeApiService()..isNewUser = false;
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      final result = await provider.verifyOtp('123456');

      expect(result, isTrue);
      expect(provider.state, AuthState.authenticated);
      expect(provider.isNewUser, isFalse);
    });

    test('failure incorrect OTP: state → error, errorMessage set', () async {
      final auth = FakeAuthService()
        ..verifyBehaviour = _VerifyOtpBehaviour.invalidCode;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      final result = await provider.verifyOtp('000000');

      expect(result, isFalse);
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, isNotEmpty);
    });

    test('failure expired OTP: state → error, message contains "expired" or "session"', () async {
      final auth = FakeAuthService()
        ..verifyBehaviour = _VerifyOtpBehaviour.expired;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      final result = await provider.verifyOtp('123456');

      expect(result, isFalse);
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, isNotNull);

      final message = provider.errorMessage!.toLowerCase();
      expect(
        message.contains('expired') || message.contains('session'),
        isTrue,
        reason: 'Expected error message to mention "expired" or "session", '
            'got: "${provider.errorMessage}"',
      );
    });

    test('verifyOtp with no verificationId: state → error', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      // Do NOT call sendOtp — verificationId is null
      final result = await provider.verifyOtp('123456');

      expect(result, isFalse);
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('AuthProvider — resendOtp', () {
    test('resendOtp triggers OTP send again, state → otpSent', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      expect(provider.state, AuthState.otpSent);

      // Track state transitions after first sendOtp completes
      final statesAfterResend = <AuthState>[];
      provider.addListener(() => statesAfterResend.add(provider.state));

      await provider.resendOtp();

      expect(statesAfterResend, contains(AuthState.sendingOtp));
      expect(statesAfterResend.last, AuthState.otpSent);
      expect(provider.state, AuthState.otpSent);
      expect(provider.verificationId, 'fake-verification-id');
    });
  });

  group('AuthProvider — clearError', () {
    test('clearError: errorMessage becomes null', () async {
      final auth = FakeAuthService()..sendBehaviour = _SendOtpBehaviour.failure;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      expect(provider.state, AuthState.error);
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
      expect(provider.state, isNot(AuthState.error));
    });

    test('clearError when no verificationId: state returns to initial', () async {
      final auth = FakeAuthService()..sendBehaviour = _SendOtpBehaviour.failure;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      expect(provider.state, AuthState.error);

      provider.clearError();

      // verificationId was not set (send failed), so state should go back to initial
      expect(provider.state, AuthState.initial);
    });

    test('clearError after failed OTP verify: state returns to otpSent', () async {
      final auth = FakeAuthService()
        ..verifyBehaviour = _VerifyOtpBehaviour.invalidCode;
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      await provider.verifyOtp('000000');
      expect(provider.state, AuthState.error);

      provider.clearError();

      // verificationId IS set (send succeeded), so state should go to otpSent
      expect(provider.state, AuthState.otpSent);
      expect(provider.errorMessage, isNull);
    });
  });

  group('AuthProvider — signOut', () {
    test('signOut: isLoggedIn is false and state is cleared', () async {
      final auth = FakeAuthService();
      final api = FakeApiService();
      final provider = await _makeProvider(authService: auth, apiService: api);

      // Authenticate first
      await provider.sendOtp('9876543210');
      await provider.verifyOtp('123456');
      expect(provider.state, AuthState.authenticated);
      expect(provider.isLoggedIn, isTrue);

      await provider.signOut();

      expect(provider.state, AuthState.initial);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.verificationId, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.phoneNumber, isNull);
      expect(provider.isNewUser, isFalse);
    });
  });

  group('AuthProvider — JWT storage after verification', () {
    test('successful verifyOtp stores token and userId in LocalStorage', () async {
      final auth = FakeAuthService();
      final api = FakeApiService()
        ..stubbedToken = 'test-jwt-abc'
        ..stubbedUserId = 'user-uuid-xyz';
      final provider = await _makeProvider(authService: auth, apiService: api);

      await provider.sendOtp('9876543210');
      await provider.verifyOtp('123456');

      expect(LocalStorageService.authToken, 'test-jwt-abc');
      expect(LocalStorageService.userId, 'user-uuid-xyz');
      expect(LocalStorageService.isLoggedIn, isTrue);
    });
  });
}
