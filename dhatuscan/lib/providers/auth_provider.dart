import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/auth_service_interface.dart';
import '../services/api_service.dart';
import '../services/api_service_interface.dart';
import '../services/local_storage_service.dart';

enum AuthState {
  initial,
  sendingOtp,
  otpSent,
  verifying,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  late final AuthServiceInterface _authService;
  late final ApiServiceInterface _apiService;

  /// Default constructor — uses the real singleton services.
  AuthProvider()
      : _authService = AuthService(),
        _apiService = ApiService();

  /// Test-only constructor — accepts injected fakes/mocks.
  @visibleForTesting
  AuthProvider.withServices({
    required AuthServiceInterface authService,
    required ApiServiceInterface apiService,
  })  : _authService = authService,
        _apiService = apiService;

  AuthState _state = AuthState.initial;
  String? _verificationId;
  String? _errorMessage;
  String? _phoneNumber;
  bool _isNewUser = false;
  UserCredential? _userCredential;

  AuthState get state => _state;
  String? get verificationId => _verificationId;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  bool get isNewUser => _isNewUser;
  bool get isLoggedIn => LocalStorageService.isLoggedIn;
  UserCredential? get userCredential => _userCredential;

  // Send OTP
  Future<void> sendOtp(String phone) async {
    _state = AuthState.sendingOtp;
    _phoneNumber = phone;
    _errorMessage = null;
    notifyListeners();

    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _state = AuthState.otpSent;
        notifyListeners();
      },
      onVerificationFailed: (error) {
        _errorMessage = _mapFirebaseError(error);
        _state = AuthState.error;
        notifyListeners();
      },
      onAutoVerify: (credential) async {
        await _signInWithCredential(credential);
      },
    );
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (_phoneNumber == null) return;
    await sendOtp(_phoneNumber!);
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _errorMessage = 'Verification session expired. Please resend OTP.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }

    _state = AuthState.verifying;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      if (credential != null) {
        _userCredential = credential;
        return await _postVerification(credential);
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Verification failed. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      _state = AuthState.verifying;
      notifyListeners();

      final userCredential =
          await _authService.signInWithCredential(credential);
      if (userCredential != null) {
        _userCredential = userCredential;
        await _postVerification(userCredential);
      }
    } catch (e) {
      _errorMessage = 'Auto-verification failed.';
      _state = AuthState.error;
      notifyListeners();
    }
  }

  Future<bool> _postVerification(UserCredential credential) async {
    try {
      final phone = _phoneNumber ?? '';
      final uid = credential.user?.uid;

      final result = await _apiService.checkUser(phone, firebaseUid: uid);

      final token = result['token'] as String?;
      final userId = result['userId'] as String?;
      _isNewUser = result['isNewUser'] as bool? ?? false;

      if (token != null) await LocalStorageService.setAuthToken(token);
      if (userId != null) await LocalStorageService.setUserId(userId);
      await LocalStorageService.setLoggedIn(true);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      // Still mark as authenticated even if backend fails (offline mode)
      _state = AuthState.authenticated;
      _isNewUser = true;
      notifyListeners();
      return true;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _state = AuthState.initial;
    _verificationId = null;
    _errorMessage = null;
    _phoneNumber = null;
    _isNewUser = false;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP session expired. Please resend OTP.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _verificationId != null ? AuthState.otpSent : AuthState.initial;
    }
    notifyListeners();
  }
}
