import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// APP COLORS — single source of truth
/// Never use raw Color() values in screens. Always use AppColors.
/// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF1F3A93);
  static const Color lightBlue     = Color(0xFF6FD3F5);
  static const Color accentBlue    = Color(0xFF304CE9);
  static const Color deepBlue      = Color(0xFF1B2B83);

  // ── Gradients ─────────────────────────────────────────────
  /// Default app gradient — headers, AppBars, hero sections
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
  );

  /// Auth / CTA gradient — login, register, confirm buttons
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1B2B83), Color(0xFF304CE9)],
  );

  /// Reversed — used in some coach screens
  static const LinearGradient reversedGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF6FD3F5), Color(0xFF1F3A93)],
  );

  // ── Backgrounds ───────────────────────────────────────────
  static const Color background      = Color(0xFFFFFFFF);
  static const Color scaffoldBg      = Color(0xFFF5F6FA);
  static const Color cardBg          = Color(0xFFFFFFFF);
  static const Color inputFill       = Color(0xFFF5F5F5);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFF000000);
  static const Color textSecondary   = Color(0xFF595959);
  static const Color textHint        = Color(0xFFAAAAAA);
  static const Color textWhite       = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────
  static const Color borderGray      = Color(0xFFA2A2A2);
  static const Color borderLight     = Color(0xFFE0E0E0);
  static const Color divider         = Color(0xFFF0F0F0);

  // ── Status ────────────────────────────────────────────────
  static const Color confirmed       = Color(0xFF4CAF50);
  static const Color confirmedLight  = Color(0xFFCFF7D3);
  static const Color pending         = Color(0xFFFFC107);
  static const Color pendingLight    = Color(0xFFFFF1B8);
  static const Color busy            = Color(0xFFFF5252);
  static const Color busyLight       = Color(0xFFFFE0E0);
  static const Color noShow          = Color(0xFFFF5252);
  static const Color noShowLight     = Color(0xFFFFEBEB);

  // ── UI elements ───────────────────────────────────────────
  static const Color disabledGray    = Color(0xFFDBDDE4);
  static const Color shadowColor     = Color(0x1A000000); // black 10%
  static const Color overlay         = Color(0x80000000); // black 50%

  // ── Semantic ──────────────────────────────────────────────
  static const Color success         = Color(0xFF4CAF50);
  static const Color successLight    = Color(0xFFE8F5E9);
  static const Color warning         = Color(0xFFFF9800);
  static const Color warningLight    = Color(0xFFFFF3E0);
  static const Color error           = Color(0xFFE53935);
  static const Color errorLight      = Color(0xFFFFEBEE);
  static const Color info            = Color(0xFF1F3A93);
  static const Color infoLight       = Color(0xFFE8F4FD);
}