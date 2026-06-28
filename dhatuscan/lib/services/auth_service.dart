import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  // Web client ID from Firebase Console → Authentication → Google → Web client ID.
  // Required on Android so Google Sign-In returns a valid ID token for the backend.
  static const String _webClientId =
      '553622699540-8nr8a243gd1gmrk966bhejlbc5e91p20.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn;

  AuthService()
      : _googleSignIn = GoogleSignIn(
          // iOS uses clientId; Android uses serverClientId to get an ID token.
          clientId: kIsWeb
              ? null
              : (Platform.isIOS
                  ? '553622699540-mc96gaunekjeuo708j73bvkr0p3nmnth.apps.googleusercontent.com'
                  : null),
          serverClientId: kIsWeb ? null : _webClientId,
          scopes: ['email', 'profile'],
        );

  /// Constructor for subclassing in tests.
  @protected
  AuthService.fromGoogleSignIn(GoogleSignIn googleSignIn)
      : _googleSignIn = googleSignIn;

  @override
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // User cancelled the sign-in dialog
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.idToken == null) {
        debugPrint('Google Sign-In: idToken is null. '
            'Ensure SHA-1 is registered in Firebase and serverClientId is correct.');
      }
      return auth.idToken;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
    await LocalStorageService.logout();
  }

  @override
  String? get googleId => _googleSignIn.currentUser?.id;
}
