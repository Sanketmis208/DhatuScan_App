import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  // Load user from cache
  void loadFromCache() {
    final data = LocalStorageService.userData;
    if (data != null) {
      _user = UserModel.fromJson(data);
      notifyListeners();
    }
  }

  // Check user by phone
  Future<bool> fetchProfile() async {
    final userId = LocalStorageService.userId;
    if (userId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getProfile(userId);
      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        _user = UserModel.fromJson(userJson);
        await LocalStorageService.setUserData(_user!.toJson());
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch profile.';
      notifyListeners();
      return false;
    }
  }

  // Save profile
  Future<bool> saveProfile(UserModel userModel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = LocalStorageService.userId;
      final data = userModel.toJson();
      if (userId != null) data['id'] = userId;

      final response = await _apiService.saveProfile(data);
      final userJson = response['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        _user = UserModel.fromJson(userJson);
        await LocalStorageService.setUserData(_user!.toJson());
        // Save userId if returned
        if (_user!.id != null) {
          await LocalStorageService.setUserId(_user!.id!);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save profile. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void setUserPhone(String phone) {
    _user = (_user ?? UserModel(phone: phone)).copyWith(phone: phone);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
