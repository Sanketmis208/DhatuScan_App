import 'package:flutter/material.dart';
import '../models/result_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Provides past assessment history for the Dashboard and Result screens.
class HistoryProvider extends ChangeNotifier {
  List<AssessmentResult> _history = [];
  AssessmentResult? _currentDetail;
  bool _isLoading = false;
  String? _errorMessage;

  List<AssessmentResult> get history => List.unmodifiable(_history);
  AssessmentResult? get currentDetail => _currentDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasHistory => _history.isNotEmpty;

  /// Latest result for the health score card on the Dashboard.
  AssessmentResult? get latest => _history.isNotEmpty ? _history.first : null;

  Future<bool> fetchHistory() async {
    final userId = LocalStorageService.userId;
    if (userId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService().getAssessmentHistory(userId);
      final list = data['assessments'] as List? ?? [];
      _history = list
          .map((e) => AssessmentResult.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load history.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchDetail(String assessmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService().getAssessment(assessmentId);
      _currentDetail = AssessmentResult.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load assessment.';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _history = [];
    _currentDetail = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
