class UserModel {
  final String? id;
  final String phone;
  final String? name;
  final DateTime? dateOfBirth;
  final int? age;
  final String? gender;
  final String? address;
  final double? height;
  final double? weight;
  final double? bmi;
  final String? bp;
  final int? pulseRate;
  final String? medicalHistory;
  final String? occupation;
  final String? physicalActivity;
  final String? sleepDuration;
  final String? appetitePattern;
  final String? waterIntake;
  final bool isProfileComplete;
  final String? firebaseUid;

  UserModel({
    this.id,
    required this.phone,
    this.name,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.address,
    this.height,
    this.weight,
    this.bmi,
    this.bp,
    this.pulseRate,
    this.medicalHistory,
    this.occupation,
    this.physicalActivity,
    this.sleepDuration,
    this.appetitePattern,
    this.waterIntake,
    this.isProfileComplete = false,
    this.firebaseUid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bp: json['bp'] as String?,
      pulseRate: json['pulseRate'] as int?,
      medicalHistory: json['medicalHistory'] as String?,
      occupation: json['occupation'] as String?,
      physicalActivity: json['physicalActivity'] as String?,
      sleepDuration: json['sleepDuration'] as String?,
      appetitePattern: json['appetitePattern'] as String?,
      waterIntake: json['waterIntake'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      firebaseUid: json['firebaseUid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'phone': phone,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bmi != null) 'bmi': bmi,
      if (bp != null) 'bp': bp,
      if (pulseRate != null) 'pulseRate': pulseRate,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      if (occupation != null) 'occupation': occupation,
      if (physicalActivity != null) 'physicalActivity': physicalActivity,
      if (sleepDuration != null) 'sleepDuration': sleepDuration,
      if (appetitePattern != null) 'appetitePattern': appetitePattern,
      if (waterIntake != null) 'waterIntake': waterIntake,
      'isProfileComplete': isProfileComplete,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    DateTime? dateOfBirth,
    int? age,
    String? gender,
    String? address,
    double? height,
    double? weight,
    double? bmi,
    String? bp,
    int? pulseRate,
    String? medicalHistory,
    String? occupation,
    String? physicalActivity,
    String? sleepDuration,
    String? appetitePattern,
    String? waterIntake,
    bool? isProfileComplete,
    String? firebaseUid,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      bp: bp ?? this.bp,
      pulseRate: pulseRate ?? this.pulseRate,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      occupation: occupation ?? this.occupation,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      appetitePattern: appetitePattern ?? this.appetitePattern,
      waterIntake: waterIntake ?? this.waterIntake,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }

  // Calculate BMI
  static double? calculateBmi(double? height, double? weight) {
    if (height == null || weight == null || height <= 0) return null;
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  // Get BMI category
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
