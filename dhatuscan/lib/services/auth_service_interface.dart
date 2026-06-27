import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Firebase-based OTP authentication.
///
/// Extracted so that [AuthProvider] can be tested with fakes
/// without requiring a live Firebase connection.
abstract class AuthServiceInterface {
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    int? resendToken,
  });

  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserCredential?> signInWithCredential(PhoneAuthCredential credential);

  Future<void> signOut();

  User? get currentUser;
  String? get firebaseUid;
}
