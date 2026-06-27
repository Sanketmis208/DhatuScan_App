import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/navigation/navigator_key.dart';
import '../core/utils/api_exception.dart';
import 'api_service_interface.dart';
import 'local_storage_service.dart';

/// Singleton HTTP client wrapper built on [Dio].
///
/// Responsibilities:
///   • Attaches `Authorization: Bearer <token>` to every request via a
///     request interceptor (Requirement 14.2).
///   • On HTTP 401, clears local auth state and navigates to `/landing`
///     via the app-wide [navigatorKey] (Requirement 14.3).
///   • Performs a connectivity pre-flight before every request; throws
///     a descriptive [ApiException] with statusCode 0 when offline
///     (Requirement 14.4).
///   • All Backend API calls use Dio (Requirement 14.1).
class ApiService implements ApiServiceInterface {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // Override with a production URL via app_config.dart or a build argument.
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-production-server.com/api';

  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  /// Protected constructor for subclassing in tests.
  @protected
  ApiService.forTest();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_JwtInterceptor());
  }

  // ── Connectivity pre-flight ───────────────────────────────────────────────

  /// Throws [ApiException] with statusCode 0 when the device is offline.
  static Future<void> _assertConnected() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network settings.',
      );
    }
  }

  // ── Response handling ─────────────────────────────────────────────────────

  /// Converts a [DioException] into an [ApiException].
  static ApiException _wrapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        statusCode: -1,
        message: 'Request timed out. Please try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
        statusCode: 0,
        message: 'Unable to reach the server. Check your connection.',
      );
    }

    final statusCode = e.response?.statusCode ?? -1;
    final data = e.response?.data;
    String message = 'Request failed';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
    }
    return ApiException(statusCode: statusCode, message: message);
  }

  /// Unwraps a successful [Response] body as [Map<String, dynamic>].
  static Map<String, dynamic> _handleResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// `POST /auth/check-user` — unauthenticated endpoint.
  ///
  /// Returns `{ token, userId, isNewUser }`.
  @override
  Future<Map<String, dynamic>> checkUser(
    String phone, {
    String? firebaseUid,
  }) async {
    await _assertConnected();
    try {
      final response = await _dio.post<dynamic>(
        '/auth/check-user',
        data: {'phone': phone, if (firebaseUid != null) 'firebaseUid': firebaseUid},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  // ── User Profile ──────────────────────────────────────────────────────────

  /// `POST /user/profile` — requires Bearer token.
  @override
  Future<Map<String, dynamic>> saveProfile(
    Map<String, dynamic> profileData,
  ) async {
    await _assertConnected();
    try {
      final response = await _dio.post<dynamic>(
        '/user/profile',
        data: profileData,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  /// `GET /user/profile/:id` — requires Bearer token.
  @override
  Future<Map<String, dynamic>> getProfile(String userId) async {
    await _assertConnected();
    try {
      final response = await _dio.get<dynamic>('/user/profile/$userId');
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  // ── Assessment ────────────────────────────────────────────────────────────

  /// `POST /assessment/submit` — requires Bearer token.
  @override
  Future<Map<String, dynamic>> submitAssessment(
    Map<String, dynamic> assessmentData,
  ) async {
    await _assertConnected();
    try {
      final response = await _dio.post<dynamic>(
        '/assessment/submit',
        data: assessmentData,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  /// `GET /assessment/history/:userId` — requires Bearer token.
  @override
  Future<Map<String, dynamic>> getAssessmentHistory(String userId) async {
    await _assertConnected();
    try {
      final response = await _dio.get<dynamic>('/assessment/history/$userId');
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }

  /// `GET /assessment/:id` — requires Bearer token.
  @override
  Future<Map<String, dynamic>> getAssessment(String assessmentId) async {
    await _assertConnected();
    try {
      final response = await _dio.get<dynamic>('/assessment/$assessmentId');
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _wrapDioError(e);
    }
  }
}

// ── Interceptors ─────────────────────────────────────────────────────────────

/// Attaches `Authorization: Bearer <token>` on every outgoing request,
/// and handles HTTP 401 by clearing auth state and navigating to `/landing`.
class _JwtInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = LocalStorageService.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorised();
    }
    handler.next(err);
  }

  /// Clears stored credentials and pushes `/landing`, removing all prior routes.
  void _handleUnauthorised() {
    LocalStorageService.logout().then((_) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil('/landing', (_) => false);
      }
    });
  }
}
