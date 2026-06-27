import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1A5C5A);
  static const Color primaryDark = Color(0xFF0D3D3B);
  static const Color primaryLight = Color(0xFF2A7D7A);

  // Accent Colors
  static const Color accent = Color(0xFFE8A838);
  static const Color accentDark = Color(0xFFD4942A);
  static const Color accentLight = Color(0xFFF0C060);

  // Background Colors
  static const Color background = Color(0xFFF5F5F0);
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFFAFAF7);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Dhatu Colors (for charts)
  static const Color rasaColor = Color(0xFF4FC3F7);
  static const Color raktaColor = Color(0xFFEF5350);
  static const Color mamsaColor = Color(0xFF66BB6A);
  static const Color medaColor = Color(0xFFFFCA28);
  static const Color asthiColor = Color(0xFF8D6E63);
  static const Color majjaColor = Color(0xFF7E57C2);
  static const Color shukraColor = Color(0xFFEC407A);

  // Gradient Colors
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D3D3B), Color(0xFF1A5C5A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A5C5A), Color(0xFF2A7D7A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A838), Color(0xFFD4942A)],
  );

  // Shadow Color
  static Color shadowColor = Colors.black.withOpacity(0.08);
}
