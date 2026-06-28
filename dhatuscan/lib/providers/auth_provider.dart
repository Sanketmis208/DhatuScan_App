import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../services/auth_service.dart';
import '../services/auth_service_interface.dart';
import '../services/api_service.dart';
import '../services/api_service_interface.dart';
import '../services/local_storage_service.dart';
import '../core/utils/api_exception.dart';

enum AuthState {
  initial,
  authenticating,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  late final AuthServiceInterface _authService;
  late final ApiServiceInterface _apiService;

  /// Default constructor — uses the real singleton services.
  AuthProvider()
      : _authService = AuthService(),
        _apiService = ApiService();

  /// Test-only constructor — accepts injected fakes/mocks.
  @visibleForTesting
  AuthProvider.withServices({
    required AuthServiceInterface authService,
    required ApiServiceInterface apiService,
  })  : _authService = authService,
        _apiService = apiService;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isNewUser = false;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isNewUser => _isNewUser;
  bool get isLoggedIn => LocalStorageService.isLoggedIn;

  /// Sign Up with Google
  Future<bool> signUp() async {
    _state = AuthState.authenticating;
    _errorMessage = null;
    _isNewUser = true;
    notifyListeners();

    try {
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) {
        _state = AuthState.initial;
        notifyListeners();
        return false;
      }

      final result = await _apiService.signUp(idToken);
      return await _postAuth(result, isSignUp: true);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      // Show the raw error message so we can diagnose the exact failure.
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = rawMsg;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Login with Google
  Future<bool> login() async {
    _state = AuthState.authenticating;
    _errorMessage = null;
    _isNewUser = false;
    notifyListeners();

    try {
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) {
        _state = AuthState.initial;
        notifyListeners();
        return false;
      }

      final result = await _apiService.login(idToken);
      return await _postAuth(result, isSignUp: false);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      // Show the raw error message so we can diagnose the exact failure.
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = rawMsg;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _postAuth(Map<String, dynamic> result, {required bool isSignUp}) async {
    try {
      final token = result['token'] as String?;
      final userId = result['userId'] as String?;
      _isNewUser = result['isNewUser'] as bool? ?? isSignUp;

      final userMap = result['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        await LocalStorageService.setUserData(userMap);
      }

      if (token != null) await LocalStorageService.setAuthToken(token);
      if (userId != null) await LocalStorageService.setUserId(userId);
      await LocalStorageService.setLoggedIn(true);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      // In case local storage storage fails, we still mark as authenticated
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _state = AuthState.initial;
    _errorMessage = null;
    _isNewUser = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
    notifyListeners();
  }
}
