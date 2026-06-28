/// All named route constants for the DhatuScan app.
///
/// Route values match those defined in the design document (design.md).
class AppRoutes {
  AppRoutes._();

  // ── Auth / Onboarding ─────────────────────────────────────────────────────
  static const String splash          = '/';
  static const String landing         = '/landing';
  static const String phoneInput      = '/phone';
  static const String otpVerify       = '/otp';
  static const String personalDetails = '/profile/new';
  static const String profileDetails = '/profile/details';

  // ── Main ──────────────────────────────────────────────────────────────────
  static const String dashboard       = '/dashboard';

  // ── Assessment ────────────────────────────────────────────────────────────
  static const String assessmentHome      = '/assessment';
  static const String section1            = '/assessment/section1';
  static const String section2            = '/assessment/section2';
  static const String result              = '/assessment/result';
  static const String recommendations     = '/assessment/recommendations';

  // ── Legacy aliases (kept for backward-compatibility during migration) ─────
  /// Alias for [phoneInput]. Prefer [phoneInput] in new code.
  static const String phone      = phoneInput;
  /// Alias for [otpVerify]. Prefer [otpVerify] in new code.
  static const String otp        = otpVerify;
  /// Alias for [personalDetails]. Prefer [personalDetails] in new code.
  static const String profileNew = personalDetails;
  /// Alias for [assessmentHome]. Prefer [assessmentHome] in new code.
  static const String assessment = assessmentHome;
  /// Alias for [result]. Used by DashboardScreen to navigate to a past result.
  static const String assessmentResult = result;
  static const String history = '/history';
}
