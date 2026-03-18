import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

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

  static const Color confirmed = Color(0xFF4CAF50);
  static const Color confirmedLight = Color(0xFFCFF7D3); // Light green background

  static const Color pending = Color(0xFFFFC107); // Yellow/Amber for pending
  static const Color pendingLight = Color(0xFFFFF1B8); // Light yellow background

  static const Color declineGray = Color(0xFFDBDDE4); // Gray for decline button

  static const Color busy = Color(0xFFFF5252); // Red for busy status
  static const Color busyLight = Color(0xFFFFE0E0); // Light red background for busy

}
