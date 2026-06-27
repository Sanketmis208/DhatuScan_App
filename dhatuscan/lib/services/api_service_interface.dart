/// Abstract interface for all backend API calls.
///
/// Extracted so that [AuthProvider] and other providers can be tested
/// with fakes that don't require a real network or Dio setup.
abstract class ApiServiceInterface {
  Future<Map<String, dynamic>> checkUser(
    String phone, {
    String? firebaseUid,
  });

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profileData);

  Future<Map<String, dynamic>> getProfile(String userId);

  Future<Map<String, dynamic>> submitAssessment(
    Map<String, dynamic> assessmentData,
  );

  Future<Map<String, dynamic>> getAssessmentHistory(String userId);

  Future<Map<String, dynamic>> getAssessment(String assessmentId);
}
