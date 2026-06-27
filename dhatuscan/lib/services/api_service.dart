import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-production-server.com/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers {
    final token = LocalStorageService.authToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> checkUser(String phone,
      {String? firebaseUid}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/check-user'),
          headers: _headers,
          body: jsonEncode({'phone': phone, 'firebaseUid': firebaseUid}),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  // User Profile
  Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> profileData) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/user/profile'),
          headers: _headers,
          body: jsonEncode(profileData),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/user/profile/$userId'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  // Assessment
  Future<Map<String, dynamic>> submitAssessment(
      Map<String, dynamic> assessmentData) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/assessment/submit'),
          headers: _headers,
          body: jsonEncode(assessmentData),
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAssessmentHistory(String userId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/assessment/history/$userId'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAssessment(String assessmentId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/assessment/$assessmentId'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] as String? ?? 'Request failed',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
