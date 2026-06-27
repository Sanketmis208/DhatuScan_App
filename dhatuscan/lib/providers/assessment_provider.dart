import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../models/result_model.dart';
import '../core/utils/score_calculator.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Assessment provider — manages Section 1 (VK) and Section 2 (Sarata) state.
/// Section 1 detail is implemented in task 7.1; this file provides the shell
/// needed by MultiProvider in main.dart plus enough state for DashboardScreen.
class AssessmentProvider extends ChangeNotifier {
  // ── Section 1 state ────────────────────────────────────────────────────────
  Map<String, DhatuVKAnswers> vkAnswers = {};
  int currentDhatuIndex = 0;
  String currentSubsection = 'vriddhi';
  bool section1Complete = false;
  List<DhatuVKResult> vkResults = [];
  String balanceStatus = '';

  // ── Section 2 state ────────────────────────────────────────────────────────
  Map<String, Map<String, bool>> sarataSelections = {};
  int currentSarataIndex = 0;
  bool section2Complete = false;
  SarataResult? sarataResult;

  // ── Submission ─────────────────────────────────────────────────────────────
  bool isSubmitting = false;
  String? errorMessage;

  // ── Section 1 methods ──────────────────────────────────────────────────────

  void setVKAnswer(String dhatu, String subsection, String symptom, int score) {
    final existing = vkAnswers[dhatu] ??
        DhatuVKAnswers(vriddhiAnswers: {}, kshayaAnswers: {});

    final updatedVriddhi = Map<String, int>.from(existing.vriddhiAnswers);
    final updatedKshaya = Map<String, int>.from(existing.kshayaAnswers);

    if (subsection == 'vriddhi') {
      updatedVriddhi[symptom] = score;
    } else {
      updatedKshaya[symptom] = score;
    }

    vkAnswers[dhatu] = DhatuVKAnswers(
      vriddhiAnswers: updatedVriddhi,
      kshayaAnswers: updatedKshaya,
    );

    // Persist immediately
    LocalStorageService.saveVKAnswers(
      vkAnswers.map((k, v) => MapEntry(k, v.toJson())),
    );

    notifyListeners();
  }

  int getKshayaMax(String dhatu, String gender) {
    if (dhatu == 'Shukra') {
      return gender == 'Male' ? 15 : 6;
    }
    return ScoreCalculator.vkMaxScores[dhatu]?['kshaya'] ?? 0;
  }

  void restoreFromCache() {
    final cached = LocalStorageService.savedVKAnswers;
    if (cached != null) {
      vkAnswers = cached.map(
        (k, v) => MapEntry(k, DhatuVKAnswers.fromJson(v as Map<String, dynamic>)),
      );
    }

    final sarataCache = LocalStorageService.savedSarataAnswers;
    if (sarataCache != null) {
      sarataSelections = sarataCache.map(
        (k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>).map((sk, sv) => MapEntry(sk, sv as bool)),
        ),
      );
    }

    notifyListeners();
  }

  void finishSection1({String? gender}) {
    vkResults = ScoreCalculator.calculateVriddhiKshaya(vkAnswers, gender: gender);
    balanceStatus = ScoreCalculator.calculateBalanceStatus(vkResults);
    section1Complete = true;
    notifyListeners();
  }

  // ── Section 2 methods ──────────────────────────────────────────────────────

  void setSarataSelection(String dhatu, String item, bool selected) {
    sarataSelections[dhatu] ??= {};
    sarataSelections[dhatu]![item] = selected;

    LocalStorageService.saveSarataAnswers(
      sarataSelections.map(
        (k, v) => MapEntry(k, v.cast<String, dynamic>()),
      ),
    );

    notifyListeners();
  }

  void finishSection2() {
    // Compute per-Sara scores from selections using SarataQuestionBank
    final scores = <String, double>{};
    for (final section in SarataQuestionBank.sections) {
      double total = 0;
      final selections = sarataSelections[section.dhatu] ?? {};
      for (final group in section.groups) {
        for (final item in group.items) {
          if (selections[item.text] == true) {
            total += item.points;
          }
        }
      }
      scores[section.dhatu] = total;
    }

    sarataResult = ScoreCalculator.calculateSarata(scores);
    section2Complete = true;
    notifyListeners();
  }

  Future<void> submitAssessment() async {
    if (sarataResult == null) return;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = LocalStorageService.userId ?? '';
      final payload = {
        'userId': userId,
        'assessmentDate': DateTime.now().toIso8601String(),
        'vkResults': vkResults.map((r) => r.toJson()).toList(),
        'sarataResult': sarataResult!.toJson(),
        'healthIndex': sarataResult!.healthIndex,
        'healthGrade': sarataResult!.healthGrade,
        'dominantSara': sarataResult!.dominantSara,
        'secondarySara': sarataResult!.secondarySara,
        'weakestSara': sarataResult!.weakestSara,
        'predominantKshaya': ScoreCalculator.getPredominantKshaya(vkResults),
        'predominantVriddhi': ScoreCalculator.getPredominantVriddhi(vkResults),
        'balanceStatus': balanceStatus,
      };

      await ApiService().submitAssessment(payload);
      await LocalStorageService.clearAssessmentProgress();
    } catch (e) {
      errorMessage = 'Failed to submit. Results saved locally.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void reset() {
    vkAnswers = {};
    currentDhatuIndex = 0;
    currentSubsection = 'vriddhi';
    section1Complete = false;
    vkResults = [];
    balanceStatus = '';

    sarataSelections = {};
    currentSarataIndex = 0;
    section2Complete = false;
    sarataResult = null;

    errorMessage = null;

    LocalStorageService.clearAssessmentProgress();
    notifyListeners();
  }
}
