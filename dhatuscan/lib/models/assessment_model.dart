class DhatuVKAnswers {
  final Map<String, int> vriddhiAnswers; // symptom -> score (0-3)
  final Map<String, int> kshayaAnswers;  // symptom -> score (0-3)

  DhatuVKAnswers({
    required this.vriddhiAnswers,
    required this.kshayaAnswers,
  });

  int get vriddhiScore =>
      vriddhiAnswers.values.fold(0, (a, b) => a + b);
  int get kshayaScore =>
      kshayaAnswers.values.fold(0, (a, b) => a + b);

  factory DhatuVKAnswers.fromJson(Map<String, dynamic> json) {
    return DhatuVKAnswers(
      vriddhiAnswers: Map<String, int>.from(
          (json['vriddhi'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, (v as num).toInt())) ??
              {}),
      kshayaAnswers: Map<String, int>.from(
          (json['kshaya'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, (v as num).toInt())) ??
              {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'vriddhi': vriddhiAnswers,
        'kshaya': kshayaAnswers,
      };

  DhatuVKAnswers copyWith({
    Map<String, int>? vriddhiAnswers,
    Map<String, int>? kshayaAnswers,
  }) {
    return DhatuVKAnswers(
      vriddhiAnswers: vriddhiAnswers ?? Map.from(this.vriddhiAnswers),
      kshayaAnswers: kshayaAnswers ?? Map.from(this.kshayaAnswers),
    );
  }
}

class AssessmentQuestion {
  final String symptom;
  final bool isMaleOnly;

  const AssessmentQuestion({
    required this.symptom,
    this.isMaleOnly = false,
  });
}

// Complete question bank for Section 1
class QuestionBank {
  static const Map<String, Map<String, List<AssessmentQuestion>>> questions = {
    'Rasa': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Excessive Salivation'),
        AssessmentQuestion(symptom: 'Loss of Appetite'),
        AssessmentQuestion(symptom: 'Tastelessness'),
        AssessmentQuestion(symptom: 'Nausea'),
        AssessmentQuestion(symptom: 'Obstruction of Channels'),
        AssessmentQuestion(symptom: 'Aversion to Sweet Taste'),
        AssessmentQuestion(symptom: 'Body Ache'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Dryness'),
        AssessmentQuestion(symptom: 'State of Illusion'),
        AssessmentQuestion(symptom: 'Wasting'),
        AssessmentQuestion(symptom: 'Tiredness without work'),
        AssessmentQuestion(symptom: 'Intolerance to Noise'),
        AssessmentQuestion(symptom: 'Palpitation/Tachycardia'),
      ],
    },
    'Rakta': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Skin Inflammation'),
        AssessmentQuestion(symptom: 'Abscess/Boils'),
        AssessmentQuestion(symptom: 'Skin Diseases'),
        AssessmentQuestion(symptom: 'Joint Inflammation'),
        AssessmentQuestion(symptom: 'Bleeding Disorders'),
        AssessmentQuestion(symptom: 'Abdominal Distension'),
        AssessmentQuestion(symptom: 'Gum Bleeding/Bruising'),
        AssessmentQuestion(symptom: 'Hyperpigmentation'),
        AssessmentQuestion(symptom: 'Digestive Disturbances'),
        AssessmentQuestion(symptom: 'Redness of Skin'),
        AssessmentQuestion(symptom: 'Redness of Eyes'),
        AssessmentQuestion(symptom: 'Blood in Urine'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Desire for Sour Taste'),
        AssessmentQuestion(symptom: 'Desire for Cold'),
        AssessmentQuestion(symptom: 'Loss of Elasticity in Veins/Skin'),
        AssessmentQuestion(symptom: 'Skin Dryness'),
      ],
    },
    'Mamsa': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Cheek Flabbiness'),
        AssessmentQuestion(symptom: 'Hypertrophy of Thigh Muscles'),
        AssessmentQuestion(symptom: 'Abdominal Enlargement'),
        AssessmentQuestion(symptom: 'Tumor or Lump'),
        AssessmentQuestion(symptom: 'Excess Fleshy Growth in Neck'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Weakness in Eyes'),
        AssessmentQuestion(symptom: 'Muscle Wasting of Cheeks/Buttocks'),
        AssessmentQuestion(symptom: 'Arthralgia'),
      ],
    },
    'Meda': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Tiredness with Palpitations'),
        AssessmentQuestion(symptom: 'Shortness of Breath'),
        AssessmentQuestion(symptom: 'Pendulous Overgrowth'),
        AssessmentQuestion(symptom: 'Very Oily Skin'),
        AssessmentQuestion(symptom: 'Prodromal signs of Diabetes'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Numbness in Lower Back'),
        AssessmentQuestion(symptom: 'Splenomegaly'),
        AssessmentQuestion(symptom: 'Lean Built'),
      ],
    },
    'Asthi': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Hypertrophy of Teeth/Extra Teeth'),
        AssessmentQuestion(symptom: 'Hypertrophy of Bone'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Asthi Shoola (Bone Pain)'),
        AssessmentQuestion(symptom: 'Cracking/Breaking of Teeth'),
        AssessmentQuestion(symptom: 'Hair Fall'),
        AssessmentQuestion(symptom: 'Brittleness of Nails'),
      ],
    },
    'Majja': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Heaviness in Eyes'),
        AssessmentQuestion(symptom: 'Heaviness in Body'),
        AssessmentQuestion(symptom: 'Thick Joints/Fat around joints'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Osteoporosis feeling'),
        AssessmentQuestion(symptom: 'State of Illusion/Dizziness'),
        AssessmentQuestion(symptom: 'Timira Darshan (Blurred Vision)'),
      ],
    },
    'Shukra': {
      'vriddhi': [
        AssessmentQuestion(symptom: 'Increased Libido'),
        AssessmentQuestion(symptom: 'Spermolith'),
      ],
      'kshaya': [
        AssessmentQuestion(symptom: 'Late Ejaculation', isMaleOnly: true),
        AssessmentQuestion(symptom: 'Blood in Semen', isMaleOnly: true),
        AssessmentQuestion(symptom: 'Pain in Penis & Testes', isMaleOnly: true),
        AssessmentQuestion(symptom: 'Burning Sensation'),
        AssessmentQuestion(symptom: 'Xerostomia (Dry Mouth)'),
      ],
    },
  };
}

// Section 2 sarata question bank
class SarataQuestionBank {
  static const List<SarataSection> sections = [
    SarataSection(
      dhatu: 'Rasa',
      maxScore: 26,
      groups: [
        SarataGroup(title: 'Skin', items: [
          SarataItem(text: 'Oily skin'),
          SarataItem(text: 'Smooth skin'),
          SarataItem(text: 'Soft skin'),
          SarataItem(text: 'Glowing skin'),
        ]),
        SarataGroup(title: 'Hair', items: [
          SarataItem(text: 'Fine hair'),
          SarataItem(text: 'Low density hair'),
          SarataItem(text: 'Medium density hair'),
          SarataItem(text: 'Strong hair roots'),
          SarataItem(text: 'Soft hair'),
        ]),
        SarataGroup(title: 'Mental/Social Traits', items: [
          SarataItem(text: 'Happy disposition'),
          SarataItem(text: 'Fortunate'),
          SarataItem(text: 'Prosperous'),
          SarataItem(text: 'Enjoys life'),
          SarataItem(text: 'Good problem-solving'),
          SarataItem(text: 'Cheerful'),
        ]),
        SarataGroup(title: 'Health Status', items: [
          SarataItem(text: 'Never ill (4 pts)', points: 4),
          SarataItem(text: '1-2 illnesses/yr (3 pts)', points: 3),
          SarataItem(text: '3-4 illnesses/yr (2 pts)', points: 2),
          SarataItem(text: '5+ illnesses/yr (1 pt)', points: 1),
        ], isSingleSelect: true),
        SarataGroup(title: 'Wound Healing', items: [
          SarataItem(text: 'Fast wound healing (2 pts)', points: 2),
          SarataItem(text: 'Normal wound healing (1 pt)', points: 1),
        ], isSingleSelect: true),
        SarataGroup(title: 'Skin Disease History', items: [
          SarataItem(text: 'Never had skin disease (2 pts)', points: 2),
          SarataItem(text: '1-2 skin diseases (1 pt)', points: 1),
        ], isSingleSelect: true),
      ],
    ),
    SarataSection(
      dhatu: 'Rakta',
      maxScore: 9,
      groups: [
        SarataGroup(title: 'Physical Features', items: [
          SarataItem(text: 'Moist/Lustrous body parts'),
          SarataItem(text: 'Reddish/Pink skin tone'),
        ]),
        SarataGroup(title: 'Mental/Behavioral', items: [
          SarataItem(text: 'Positive mindset'),
          SarataItem(text: 'Determined'),
          SarataItem(text: 'Self-controlled'),
        ]),
        SarataGroup(title: 'Body Sensitivity', items: [
          SarataItem(text: 'Sensitive skin'),
          SarataItem(text: 'Gets tired easily'),
          SarataItem(text: 'Low pain tolerance'),
          SarataItem(text: 'Heat intolerance'),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Mamsa',
      maxScore: 14,
      groups: [
        SarataGroup(title: 'Physical Features', items: [
          SarataItem(text: 'Firm & well-built body'),
          SarataItem(text: 'Heavy/well-developed frame'),
          SarataItem(text: 'Compact/well-toned muscles'),
          SarataItem(text: 'Well-developed muscle tone'),
        ]),
        SarataGroup(title: 'Mental/Behavioral', items: [
          SarataItem(text: 'Forgiving nature'),
          SarataItem(text: 'Patient'),
          SarataItem(text: 'Honest'),
          SarataItem(text: 'Believes health is wealth'),
          SarataItem(text: 'Loves learning'),
          SarataItem(text: 'Happy with strength'),
        ]),
        SarataGroup(title: 'Strength & Recovery', items: [
          SarataItem(text: 'Recovers quickly from illness'),
          SarataItem(text: 'Good physical strength'),
          SarataItem(text: 'Sustained strength over time'),
          SarataItem(text: 'Well-built since childhood'),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Meda',
      maxScore: 21,
      groups: [
        SarataGroup(title: 'Skin, Hair & Body', items: [
          SarataItem(text: 'Oily/unctuous skin'),
          SarataItem(text: 'Watery/moist eyes'),
          SarataItem(text: 'Dry hair/scalp'),
          SarataItem(text: 'Rough body hair'),
          SarataItem(text: 'Strong nails'),
          SarataItem(text: 'Brittle nails'),
          SarataItem(text: 'Lustrous teeth'),
          SarataItem(text: 'Soft lips'),
          SarataItem(text: 'Unctuous body overall'),
          SarataItem(text: 'Bulky build'),
        ]),
        SarataGroup(title: 'Voice & Body Functions', items: [
          SarataItem(text: 'Voice cracking'),
          SarataItem(text: 'Straining in urination'),
          SarataItem(text: 'Easy bowel movement'),
          SarataItem(text: 'Excess sweating'),
        ]),
        SarataGroup(title: 'Strength & Tolerance', items: [
          SarataItem(text: 'Gets tired easily'),
          SarataItem(text: 'High drug tolerance'),
        ]),
        SarataGroup(title: 'Lifestyle & Nature', items: [
          SarataItem(text: 'Sedentary work preference'),
          SarataItem(text: 'Prefers physical work'),
          SarataItem(text: 'Comfort in sedentary lifestyle'),
          SarataItem(text: 'Luxury-loving'),
          SarataItem(text: 'Humble nature'),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Asthi',
      maxScore: 10,
      groups: [
        SarataGroup(title: 'Physical Features', items: [
          SarataItem(text: 'Prominent bones'),
          SarataItem(text: 'Large & strong teeth'),
          SarataItem(text: 'Broad shoulders'),
        ]),
        SarataGroup(title: 'Strength & Activity', items: [
          SarataItem(text: 'Enthusiastic'),
          SarataItem(text: 'Good endurance'),
          SarataItem(text: 'Stable body'),
          SarataItem(text: 'Always active'),
          SarataItem(text: 'Firm & strong body'),
        ]),
        SarataGroup(title: 'Longevity', items: [
          SarataItem(text: 'Family history of long life (2 pts)', points: 2),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Majja',
      maxScore: 11,
      groups: [
        SarataGroup(title: 'Physical Features', items: [
          SarataItem(text: 'Soft body parts'),
          SarataItem(text: 'Soft & unctuous complexion'),
          SarataItem(text: 'Broad joints'),
          SarataItem(text: 'Large eyes'),
        ]),
        SarataGroup(title: 'Strength & Stability', items: [
          SarataItem(text: 'Good strength for strenuous work'),
          SarataItem(text: 'Stable physique'),
        ]),
        SarataGroup(title: 'Voice', items: [
          SarataItem(text: 'Pleasant & smooth voice'),
          SarataItem(text: 'High-pitched voice'),
        ]),
        SarataGroup(title: 'Mental/Cognitive', items: [
          SarataItem(text: 'Good listener'),
          SarataItem(text: 'Inclined towards learning'),
          SarataItem(text: 'Adequate resources/wealth'),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Shukra',
      maxScore: 20,
      groups: [
        SarataGroup(title: 'Nature & Attraction', items: [
          SarataItem(text: 'Calm & gentle nature'),
          SarataItem(text: 'Pleasant personality'),
          SarataItem(text: 'High attraction/charm'),
          SarataItem(text: 'Respected & trusted'),
        ]),
        SarataGroup(title: 'Eyes & Complexion', items: [
          SarataItem(text: 'Clear sclera (whites of eyes)'),
          SarataItem(text: 'Healthy & glowing skin'),
          SarataItem(text: 'Unctuous/oily face'),
          SarataItem(text: 'Radiant appearance'),
        ]),
        SarataGroup(title: 'Teeth & Nails', items: [
          SarataItem(text: 'Strong & shiny teeth'),
          SarataItem(text: 'Symmetrical teeth'),
          SarataItem(text: 'Properly aligned teeth'),
          SarataItem(text: 'Lustrous nails'),
        ]),
        SarataGroup(title: 'Voice', items: [
          SarataItem(text: 'Pleasant voice'),
          SarataItem(text: 'Soft voice'),
        ]),
        SarataGroup(title: 'Body & Strength', items: [
          SarataItem(text: 'Well-developed hips'),
          SarataItem(text: 'Strong body'),
        ]),
        SarataGroup(title: 'Lifestyle & Well-being', items: [
          SarataItem(text: 'Happy despite ups & downs'),
          SarataItem(text: 'Comfort/luxury present'),
          SarataItem(text: 'Generally healthy'),
          SarataItem(text: 'Financially stable'),
        ]),
      ],
    ),
    SarataSection(
      dhatu: 'Satva',
      maxScore: 15,
      groups: [
        SarataGroup(title: 'Learning & Intellect', items: [
          SarataItem(text: 'Quick learner'),
          SarataItem(text: 'Multi-tasking ability'),
          SarataItem(text: 'Thought-action alignment'),
        ]),
        SarataGroup(title: 'Emotional Strength', items: [
          SarataItem(text: 'Self-controlled'),
          SarataItem(text: 'Strong determination'),
          SarataItem(text: 'Calm despite situations'),
          SarataItem(text: 'Stable after stress'),
        ]),
        SarataGroup(title: 'Behavior & Values', items: [
          SarataItem(text: 'Grateful'),
          SarataItem(text: 'Forgiving'),
          SarataItem(text: 'Clean & organized'),
          SarataItem(text: 'Pleasant behavior'),
          SarataItem(text: 'Inclined towards virtuous acts'),
        ]),
        SarataGroup(title: 'Enthusiasm & Devotion', items: [
          SarataItem(text: 'Dedicated towards goals'),
          SarataItem(text: 'Enjoys small things in life'),
        ]),
        SarataGroup(title: 'Physical Strength', items: [
          SarataItem(text: 'Handles physical work easily'),
        ]),
      ],
    ),
  ];
}

class SarataSection {
  final String dhatu;
  final int maxScore;
  final List<SarataGroup> groups;

  const SarataSection({
    required this.dhatu,
    required this.maxScore,
    required this.groups,
  });
}

class SarataGroup {
  final String title;
  final List<SarataItem> items;
  final bool isSingleSelect;

  const SarataGroup({
    required this.title,
    required this.items,
    this.isSingleSelect = false,
  });
}

class SarataItem {
  final String text;
  final int points;

  const SarataItem({required this.text, this.points = 1});
}
