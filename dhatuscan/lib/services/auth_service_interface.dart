/// Abstract interface for Google OAuth authentication.
///
/// Extracted so that [AuthProvider] can be tested with fakes
/// without requiring a live Google/Firebase connection.
abstract class AuthServiceInterface {
  /// Initiates Google Sign-In and returns the Google ID Token.
  Future<String?> signInWithGoogle();

  /// Logs out of Google.
  Future<void> signOut();

  /// The unique Google ID of the currently logged-in user, if any.
  String? get googleId;
}
