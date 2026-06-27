import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'local_storage_service.dart';

/// A [GlobalKey] for the root [Navigator]. Callers must assign this key to
/// [MaterialApp.navigatorKey] so the 401 interceptor can push the landing
/// route without a [BuildContext].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-production-server.com/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Request interceptor: attach JWT ──────────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalStorageService.authToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // ── Response interceptor: catch 401 ─────────────────────────────────
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await LocalStorageService.logout();
            // Navigate to /landing and remove all previous routes from the
            // stack so the user cannot navigate back.
            navigatorKey.currentState
                ?.pushNamedAndRemoveUntil('/landing', (_) => false);
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ── Connectivity pre-flight ──────────────────────────────────────────────

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final isOffline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    if (isOffline) {
      throw const ApiException(
        statusCode: 0,
        message:
            'No internet connection. Please check your network and try again.',
      );
    }
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkUser(String phone,
      {String? firebaseUid}) async {
    await _checkConnectivity();
    final response = await _dio.post(
      '/auth/check-user',
      data: {'phone': phone, 'firebaseUid': firebaseUid},
    );
    return _handleResponse(response);
  }

  // ── User Profile ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> profileData) async {
    await _checkConnectivity();
    final response = await _dio.post('/user/profile', data: profileData);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    await _checkConnectivity();
    final response = await _dio.get('/user/profile/$userId');
    return _handleResponse(response);
  }

  // ── Assessment ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitAssessment(
      Map<String, dynamic> assessmentData) async {
    await _checkConnectivity();
    final response = await _dio.post(
      '/assessment/submit',
      data: assessmentData,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAssessmentHistory(String userId) async {
    await _checkConnectivity();
    final response = await _dio.get('/assessment/history/$userId');
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAssessment(String assessmentId) async {
    await _checkConnectivity();
    final response = await _dio.get('/assessment/$assessmentId');
    return _handleResponse(response);
  }

  // ── Response handler ─────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    // Defensive: return an empty map if the body is not an object.
    return {};
  }
}

// ── Exceptions ──────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ── Dio error → ApiException translation ────────────────────────────────────

/// Converts a [DioException] thrown by [Dio] into an [ApiException] so
/// callers do not need to depend on `dio` directly.
ApiException dioExceptionToApiException(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.unknown) {
    return const ApiException(
      statusCode: 0,
      message:
          'No internet connection. Please check your network and try again.',
    );
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const ApiException(
      statusCode: 0,
      message: 'Request timed out. Please try again.',
    );
  }
  final statusCode = e.response?.statusCode ?? 0;
  final body = e.response?.data;
  String message = 'Request failed';
  if (body is Map<String, dynamic>) {
    message = body['message'] as String? ?? message;
  }
  return ApiException(statusCode: statusCode, message: message);
}
