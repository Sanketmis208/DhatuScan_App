import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final FirebaseAuth? _firebaseAuth;

  AuthService() : _firebaseAuth = _getFirebaseAuth();

  static FirebaseAuth? _getFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase is not initialized. AuthService running in fallback/error mode.');
      return null;
    }
  }

  /// Constructor for subclassing in tests — avoids accessing [FirebaseAuth.instance].
  @protected
  AuthService.fromFirebaseAuth(FirebaseAuth firebaseAuth)
      : _firebaseAuth = firebaseAuth;

  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  // Send OTP via Firebase
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    int? resendToken,
  }) async {
    if (_firebaseAuth == null) {
      onVerificationFailed(FirebaseAuthException(
        code: 'not-initialized',
        message: 'Firebase is not initialized. Please verify your config files.',
      ));
      return;
    }
    await _firebaseAuth!.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerify(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        _verificationId = verificationId;
        _resendToken = forceResendingToken;
        onCodeSent(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Resend OTP
  Future<void> resendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
      onAutoVerify: onAutoVerify,
      resendToken: _resendToken,
    );
  }

  // Verify OTP
  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (_firebaseAuth == null) {
      throw FirebaseAuthException(
        code: 'not-initialized',
        message: 'Firebase is not initialized.',
      );
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _firebaseAuth!.signInWithCredential(credential);
  }

  // Sign in with credential
  Future<UserCredential?> signInWithCredential(
      PhoneAuthCredential credential) async {
    if (_firebaseAuth == null) {
      throw FirebaseAuthException(
        code: 'not-initialized',
        message: 'Firebase is not initialized.',
      );
    }
    return await _firebaseAuth!.signInWithCredential(credential);
  }

  // Get current user
  User? get currentUser => _firebaseAuth?.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth?.signOut();
    await LocalStorageService.logout();
  }

  // Get Firebase UID
  String? get firebaseUid => _firebaseAuth?.currentUser?.uid;
}
