import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  // Web client ID from Firebase Console → Authentication → Google.
  // On Android, serverClientId is required to get a valid idToken.
  static const String _webClientId =
      '553622699540-8nr8a243gd1gmrk966bhejlbc5e91p20.apps.googleusercontent.com';

  // iOS client ID from google-services — used on iOS only.
  static const String _iosClientId =
      '553622699540-mc96gaunekjeuo708j73bvkr0p3nmnth.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      // On Android: serverClientId makes Google return an idToken the backend can verify.
      // On iOS: clientId is used directly.
      // Do NOT set clientId on Android — it causes PlatformException(sign_in_failed).
      clientId: (!kIsWeb && Platform.isIOS) ? _iosClientId : null,
      serverClientId: kIsWeb ? null : _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  /// Constructor for subclassing in tests.
  @protected
  AuthService.fromGoogleSignIn(GoogleSignIn googleSignIn)
      : _googleSignIn = googleSignIn;

  @override
  Future<String?> signInWithGoogle() async {
    try {
      // Sign out first to force the account picker — prevents stale token issues.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the picker — not an error.
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        debugPrint(
          'AuthService: idToken is null after successful sign-in.\n'
          'Check that:\n'
          '  1. SHA-1 fingerprint is registered in Firebase Console\n'
          '  2. serverClientId matches the Web OAuth client ID in Firebase\n'
          '  3. google-services.json is up to date\n'
          '  4. Google Sign-In is enabled in Firebase Authentication',
        );
        throw Exception(
          'Could not get authentication token. '
          'Please check your internet connection and try again.',
        );
      }

      return auth.idToken;
    } on Exception catch (e) {
      final msg = e.toString();
      debugPrint('AuthService.signInWithGoogle error: $msg');

      // Translate common PlatformException codes to readable messages.
      if (msg.contains('sign_in_cancelled') || msg.contains('12501')) {
        return null; // User cancelled — not an error
      }
      if (msg.contains('sign_in_failed') || msg.contains(' 10:') || msg.contains('code: 10')) {
        // Error 10 = SHA-1 not registered OR wrong serverClientId.
        // The SHA-1 registered in Firebase must match the keystore used to sign the APK.
        throw Exception(
          'Google Sign-In error 10: SHA-1 fingerprint mismatch. '
          'Ensure the debug SHA-1 (7B:2A:F6:0B:03:95:F8:08:9B) is registered in Firebase Console.',
        );
      }
      if (msg.contains('network_error') || msg.contains('7:')) {
        throw Exception(
          'Network error during sign-in. '
          'Please check your internet connection.',
        );
      }

      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
    }
    await LocalStorageService.logout();
  }

  @override
  String? get googleId => _googleSignIn.currentUser?.id;
}
