/// Abstract interface for all backend API calls.
///
/// Extracted so that [AuthProvider] and other providers can be tested
/// with fakes that don't require a real network or Dio setup.
abstract class ApiServiceInterface {
  /// Authenticates a user via Google ID token.
  Future<Map<String, dynamic>> login(String idToken);

  /// Registers a new user via Google ID token.
  Future<Map<String, dynamic>> signUp(String idToken);

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profileData);

  Future<Map<String, dynamic>> getProfile(String userId);

  Future<Map<String, dynamic>> submitAssessment(
    Map<String, dynamic> assessmentData,
  );

  Future<Map<String, dynamic>> getAssessmentHistory(String userId);

  Future<Map<String, dynamic>> getAssessment(String assessmentId);
}
