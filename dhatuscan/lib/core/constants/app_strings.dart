class AppStrings {
  // App Info
  static const String appName = 'DhatuScan';
  static const String appNameHindi = 'धातु';
  static const String tagline = 'Swasthya ka Sahi Scan';
  static const String appSubtitle =
      'Read the balance of your seven bodily tissues — the way Ayurveda has for centuries.';

  // Auth Strings
  static const String phoneInputTitle = 'Enter Your Phone';
  static const String phoneInputSubtitle = 'We\'ll send you a verification code';
  static const String phoneHint = '10-digit mobile number';
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify & Continue';
  static const String resendOtp = 'Resend OTP';
  static const String otpSentTo = 'OTP sent to +91';
  static const String otpVerificationTitle = 'Verify OTP';
  static const String otpVerificationSubtitle = 'Enter the 6-digit code sent to';

  // Onboarding
  static const String personalDetailsTitle = 'Personal Details';
  static const String lifestyleDetailsTitle = 'Lifestyle Details';
  static const String nameLabel = 'Full Name';
  static const String dobLabel = 'Date of Birth';
  static const String ageLabel = 'Age (years)';
  static const String genderLabel = 'Gender';
  static const String mobileLabel = 'Mobile Number';
  static const String addressLabel = 'Address';
  static const String heightLabel = 'Height (cm)';
  static const String weightLabel = 'Weight (kg)';
  static const String bmiLabel = 'BMI';
  static const String bpLabel = 'Blood Pressure';
  static const String pulseLabel = 'Pulse Rate (bpm)';
  static const String medicalHistoryLabel = 'Medical History';
  static const String occupationLabel = 'Occupation';
  static const String physicalActivityLabel = 'Physical Activity Level';
  static const String sleepDurationLabel = 'Sleep Duration';
  static const String appetiteLabel = 'Appetite Pattern';
  static const String waterIntakeLabel = 'Water Intake';

  // Dashboard
  static const String namaste = 'Namaste';
  static const String startAssessment = 'Start New Assessment';
  static const String recentAssessments = 'Recent Assessments';
  static const String noAssessments = 'No assessments yet.\nTake your first scan!';

  // Assessment
  static const String section1Title = 'Dhatu Vriddhi-Kshaya';
  static const String section1Subtitle = 'Symptom-based assessment (4-point scale)';
  static const String section2Title = 'Dhatu Sarata';
  static const String section2Subtitle = 'Constitution-based assessment (checkboxes)';
  static const String vriddhiLabel = 'Vriddhi (Excess)';
  static const String kshayaLabel = 'Kshaya (Deficiency)';

  // Score Labels
  static const String noChange = 'No Significant Change';
  static const String mild = 'Mild';
  static const String moderate = 'Moderate';
  static const String severe = 'Severe';

  static const String samaDhatu = 'Sama Dhatu (Well Balanced)';
  static const String mildImbalance = 'Mild Imbalance';
  static const String moderateImbalance = 'Moderate Imbalance';
  static const String severeImbalance = 'Severe Imbalance';

  static const String poor = 'Poor';
  static const String fair = 'Fair';
  static const String good = 'Good';
  static const String excellent = 'Excellent';

  // Dhatu Names
  static const List<String> dhatuNames = [
    'Rasa', 'Rakta', 'Mamsa', 'Meda', 'Asthi', 'Majja', 'Shukra'
  ];

  // Result
  static const String resultTitle = 'Assessment Results';
  static const String healthIndex = 'Health Index';
  static const String viewRecommendations = 'View Recommendations →';
  static const String dominantSara = 'Dominant Sara';
  static const String secondarySara = 'Secondary Sara';
  static const String weakestSara = 'Weakest Sara';

  // Buttons
  static const String beginAssessment = 'Begin Assessment →';
  static const String alreadyHaveAccount = 'I already have an account';
  static const String saveAndContinue = 'Save & Continue';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String submit = 'Submit Assessment';

  // Errors
  static const String errorRequired = 'This field is required';
  static const String errorInvalidPhone = 'Please enter a valid 10-digit number';
  static const String errorOtpFailed = 'OTP verification failed. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}
