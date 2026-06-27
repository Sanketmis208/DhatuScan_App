class DhatuVKResult {
  final String dhatu;
  final int vriddhiScore;
  final int kshayaScore;
  final int vriddhiMax;
  final int kshayaMax;
  final double vriddhiPercent;
  final double kshayaPercent;
  final String vriddhiStatus;
  final String kshayaStatus;
  final String dominant;

  DhatuVKResult({
    required this.dhatu,
    required this.vriddhiScore,
    required this.kshayaScore,
    required this.vriddhiMax,
    required this.kshayaMax,
    required this.vriddhiPercent,
    required this.kshayaPercent,
    required this.vriddhiStatus,
    required this.kshayaStatus,
    required this.dominant,
  });

  factory DhatuVKResult.fromJson(Map<String, dynamic> json) {
    return DhatuVKResult(
      dhatu: json['dhatu'] as String,
      vriddhiScore: json['vriddhiScore'] as int,
      kshayaScore: json['kshayaScore'] as int,
      vriddhiMax: json['vriddhiMax'] as int,
      kshayaMax: json['kshayaMax'] as int,
      vriddhiPercent: (json['vriddhiPercent'] as num).toDouble(),
      kshayaPercent: (json['kshayaPercent'] as num).toDouble(),
      vriddhiStatus: json['vriddhiStatus'] as String,
      kshayaStatus: json['kshayaStatus'] as String,
      dominant: json['dominant'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'dhatu': dhatu,
        'vriddhiScore': vriddhiScore,
        'kshayaScore': kshayaScore,
        'vriddhiMax': vriddhiMax,
        'kshayaMax': kshayaMax,
        'vriddhiPercent': vriddhiPercent,
        'kshayaPercent': kshayaPercent,
        'vriddhiStatus': vriddhiStatus,
        'kshayaStatus': kshayaStatus,
        'dominant': dominant,
      };
}

class SarataResult {
  final Map<String, double> scores;
  final double totalScore;
  final double healthIndex;
  final String healthGrade;
  final String dominantSara;
  final String secondarySara;
  final String weakestSara;

  SarataResult({
    required this.scores,
    required this.totalScore,
    required this.healthIndex,
    required this.healthGrade,
    required this.dominantSara,
    required this.secondarySara,
    required this.weakestSara,
  });

  factory SarataResult.fromJson(Map<String, dynamic> json) {
    return SarataResult(
      scores: Map<String, double>.from(
          (json['scores'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()))),
      totalScore: (json['totalScore'] as num).toDouble(),
      healthIndex: (json['healthIndex'] as num).toDouble(),
      healthGrade: json['healthGrade'] as String,
      dominantSara: json['dominantSara'] as String,
      secondarySara: json['secondarySara'] as String,
      weakestSara: json['weakestSara'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'scores': scores,
        'totalScore': totalScore,
        'healthIndex': healthIndex,
        'healthGrade': healthGrade,
        'dominantSara': dominantSara,
        'secondarySara': secondarySara,
        'weakestSara': weakestSara,
      };
}

class AssessmentResult {
  final String? id;
  final String userId;
  final DateTime assessmentDate;
  final List<DhatuVKResult> vkResults;
  final SarataResult sarataResult;
  final double healthIndex;
  final String healthGrade;
  final String dominantSara;
  final String secondarySara;
  final String weakestSara;
  final String predominantKshaya;
  final String predominantVriddhi;
  final String balanceStatus;

  AssessmentResult({
    this.id,
    required this.userId,
    required this.assessmentDate,
    required this.vkResults,
    required this.sarataResult,
    required this.healthIndex,
    required this.healthGrade,
    required this.dominantSara,
    required this.secondarySara,
    required this.weakestSara,
    required this.predominantKshaya,
    required this.predominantVriddhi,
    required this.balanceStatus,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      vkResults: (json['vkResults'] as List)
          .map((e) => DhatuVKResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      sarataResult:
          SarataResult.fromJson(json['sarataResult'] as Map<String, dynamic>),
      healthIndex: (json['healthIndex'] as num).toDouble(),
      healthGrade: json['healthGrade'] as String,
      dominantSara: json['dominantSara'] as String,
      secondarySara: json['secondarySara'] as String,
      weakestSara: json['weakestSara'] as String,
      predominantKshaya: json['predominantKshaya'] as String,
      predominantVriddhi: json['predominantVriddhi'] as String,
      balanceStatus: json['balanceStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': userId,
        'assessmentDate': assessmentDate.toIso8601String(),
        'vkResults': vkResults.map((r) => r.toJson()).toList(),
        'sarataResult': sarataResult.toJson(),
        'healthIndex': healthIndex,
        'healthGrade': healthGrade,
        'dominantSara': dominantSara,
        'secondarySara': secondarySara,
        'weakestSara': weakestSara,
        'predominantKshaya': predominantKshaya,
        'predominantVriddhi': predominantVriddhi,
        'balanceStatus': balanceStatus,
      };
}
