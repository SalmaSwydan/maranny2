import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

<<<<<<< HEAD
  // =========================
  // BRAND GRADIENTS
  // =========================

  /// Main app gradient (MOST USED)
  /// Home, Bookings, Accept buttons, AppBars
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6FD3F5), // light blue
      Color(0xFF1F3A93), // deep blue
    ],
  );

  /// Strong CTA / Auth gradient
  /// Login, Register, Complete Registration
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF304CE9),
      Color(0xFF1B2B83),
    ],
  );

  // =========================
  // SOLID COLORS
  // =========================

  static const Color primaryBlue = Color(0xFF1F3A93);
  static const Color lightBlue = Color(0xFF6FD3F5);

  static const Color disabledGray = Color(0xFFDBDDE4);
  static const Color borderGray = Color(0xFFA2A2A2);

  static const Color authButtonStroke = Color(0xFF0A2A66);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF595959);

  static const Color background = Color(0xFFFFFFFF);
=======
>>>>>>> 3fb84c9407145f53192b21ceeee81835c22f8896
}
