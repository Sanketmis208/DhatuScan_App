import '../../models/assessment_model.dart';
import '../../models/result_model.dart';

class ScoreCalculator {
  // Vriddhi/Kshaya max scores per dhatu
  static const Map<String, Map<String, int>> vkMaxScores = {
    'Rasa': {'vriddhi': 21, 'kshaya': 18},
    'Rakta': {'vriddhi': 36, 'kshaya': 12},
    'Mamsa': {'vriddhi': 15, 'kshaya': 9},
    'Meda': {'vriddhi': 15, 'kshaya': 9},
    'Asthi': {'vriddhi': 6, 'kshaya': 12},
    'Majja': {'vriddhi': 9, 'kshaya': 9},
    'Shukra': {'vriddhi': 6, 'kshaya': 15},
  };

  static const int sarataMaxScore = 126;

  // Calculate Vriddhi-Kshaya results for each dhatu
  static List<DhatuVKResult> calculateVriddhiKshaya(
      Map<String, DhatuVKAnswers> answers) {
    List<DhatuVKResult> results = [];

    for (final dhatu in vkMaxScores.keys) {
      final dhatuAnswers = answers[dhatu];
      if (dhatuAnswers == null) continue;

      final vMax = vkMaxScores[dhatu]!['vriddhi']!;
      final kMax = vkMaxScores[dhatu]!['kshaya']!;

      final vScore = dhatuAnswers.vriddhiScore;
      final kScore = dhatuAnswers.kshayaScore;

      final vPercent = vMax > 0 ? (vScore / vMax) * 100 : 0.0;
      final kPercent = kMax > 0 ? (kScore / kMax) * 100 : 0.0;

      results.add(DhatuVKResult(
        dhatu: dhatu,
        vriddhiScore: vScore,
        kshayaScore: kScore,
        vriddhiMax: vMax,
        kshayaMax: kMax,
        vriddhiPercent: vPercent,
        kshayaPercent: kPercent,
        vriddhiStatus: _getVKStatus(vPercent),
        kshayaStatus: _getVKStatus(kPercent),
        dominant: _getDominant(vPercent, kPercent),
      ));
    }

    return results;
  }

  static String _getVKStatus(double percent) {
    if (percent < 40) return 'No Significant Change';
    if (percent < 60) return 'Mild';
    if (percent < 80) return 'Moderate';
    return 'Severe';
  }

  static String _getDominant(double vPercent, double kPercent) {
    if (vPercent > kPercent) return 'Vriddhi';
    if (kPercent > vPercent) return 'Kshaya';
    return 'Balanced';
  }

  // Calculate Sarata results
  static SarataResult calculateSarata(Map<String, double> sarataScores) {
    final total = sarataScores.values.fold(0.0, (a, b) => a + b);
    final healthIndex = (total / sarataMaxScore) * 100;

    // Sort saratas by score descending
    final sorted = sarataScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SarataResult(
      scores: sarataScores,
      totalScore: total,
      healthIndex: healthIndex,
      healthGrade: _getHealthGrade(healthIndex),
      dominantSara: sorted.isNotEmpty ? sorted[0].key : '',
      secondarySara: sorted.length > 1 ? sorted[1].key : '',
      weakestSara: sorted.isNotEmpty ? sorted.last.key : '',
    );
  }

  static String _getHealthGrade(double healthIndex) {
    if (healthIndex <= 40) return 'Poor';
    if (healthIndex <= 60) return 'Fair';
    if (healthIndex <= 80) return 'Good';
    return 'Excellent';
  }

  // Calculate overall balance status
  static String calculateBalanceStatus(List<DhatuVKResult> vkResults) {
    int affectedCount = vkResults.where((r) =>
        r.vriddhiStatus != 'No Significant Change' ||
        r.kshayaStatus != 'No Significant Change').length;

    if (affectedCount == 0) return 'Sama Dhatu (Well Balanced)';
    if (affectedCount <= 2) return 'Mild Imbalance';
    if (affectedCount <= 4) return 'Moderate Imbalance';
    return 'Severe Imbalance';
  }

  // Get predominant Kshaya dhatu
  static String getPredominantKshaya(List<DhatuVKResult> results) {
    DhatuVKResult? worst;
    for (final r in results) {
      if (r.kshayaStatus != 'No Significant Change') {
        if (worst == null || r.kshayaPercent > worst.kshayaPercent) {
          worst = r;
        }
      }
    }
    return worst?.dhatu ?? 'None';
  }

  // Get predominant Vriddhi dhatu
  static String getPredominantVriddhi(List<DhatuVKResult> results) {
    DhatuVKResult? worst;
    for (final r in results) {
      if (r.vriddhiStatus != 'No Significant Change') {
        if (worst == null || r.vriddhiPercent > worst.vriddhiPercent) {
          worst = r;
        }
      }
    }
    return worst?.dhatu ?? 'None';
  }

  // Get top affected dhatus for recommendations (max 3, priority: Severe > Moderate > Mild)
  static List<AffectedDhatu> getTopAffectedDhatus(
      List<DhatuVKResult> vkResults) {
    List<AffectedDhatu> affected = [];

    for (final r in vkResults) {
      // Check Vriddhi
      if (r.vriddhiStatus != 'No Significant Change') {
        affected.add(AffectedDhatu(
          dhatu: r.dhatu,
          type: 'Vriddhi',
          status: r.vriddhiStatus,
          percent: r.vriddhiPercent,
        ));
      }
      // Check Kshaya
      if (r.kshayaStatus != 'No Significant Change') {
        affected.add(AffectedDhatu(
          dhatu: r.dhatu,
          type: 'Kshaya',
          status: r.kshayaStatus,
          percent: r.kshayaPercent,
        ));
      }
    }

    // Sort by severity then percentage
    final statusOrder = {'Severe': 0, 'Moderate': 1, 'Mild': 2};
    affected.sort((a, b) {
      final statusComp = (statusOrder[a.status] ?? 3)
          .compareTo(statusOrder[b.status] ?? 3);
      if (statusComp != 0) return statusComp;
      return b.percent.compareTo(a.percent);
    });

    return affected.take(3).toList();
  }
}

class AffectedDhatu {
  final String dhatu;
  final String type; // 'Vriddhi' or 'Kshaya'
  final String status;
  final double percent;

  AffectedDhatu({
    required this.dhatu,
    required this.type,
    required this.status,
    required this.percent,
  });
}
