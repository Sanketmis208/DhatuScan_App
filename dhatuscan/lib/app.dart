import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/navigation/navigator_key.dart';
import 'core/theme/app_theme.dart';
import 'screens/assessment/assessment_home_screen.dart';
import 'screens/assessment/section1_screen.dart';
import 'screens/assessment/section2_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/onboarding/personal_details_screen.dart';
import 'screens/recommendations/recommendations_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/splash/splash_screen.dart';

class DhatuScanApp extends StatelessWidget {
  const DhatuScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DhatuScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // The navigatorKey is shared with ApiService so the 401 interceptor
      // can push /landing without a BuildContext.
      navigatorKey: navigatorKey,

      initialRoute: AppRoutes.splash,
      routes: {
        // ── Auth / Onboarding ───────────────────────────────────────────────
        AppRoutes.splash:          (_) => const SplashScreen(),
        AppRoutes.landing:         (_) => const LandingScreen(),
        AppRoutes.phoneInput:      (_) => const PhoneInputScreen(),
        AppRoutes.otpVerify:       (_) => const OtpVerificationScreen(),
        AppRoutes.personalDetails: (_) => const PersonalDetailsScreen(),

        // ── Main ────────────────────────────────────────────────────────────
        AppRoutes.dashboard:       (_) => const DashboardScreen(),

        // ── Assessment ──────────────────────────────────────────────────────
        AppRoutes.assessmentHome:  (_) => const AssessmentHomeScreen(),
        AppRoutes.section1:        (_) => const Section1Screen(),
        AppRoutes.section2:        (_) => const Section2Screen(),
        AppRoutes.result:          (_) => const ResultScreen(),
        AppRoutes.recommendations: (_) => const RecommendationsScreen(),
      },

      // Unknown route fallback
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const SplashScreen(),
      ),
    );
  }
}
