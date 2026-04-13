import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ─────────────────────────────────────────────────────────────
/// APP TEXT STYLES — single source of truth
/// Poppins  → headings, titles, buttons
/// Inter    → body, labels, captions
///
/// Usage:  Text('Hello', style: AppTextStyles.h2)
/// ─────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // ── Headings (Poppins) ────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins', fontSize: 32,
    fontWeight: FontWeight.bold, color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins', fontSize: 26,
    fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Poppins', fontSize: 20,
    fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: 'Poppins', fontSize: 18,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h5 = TextStyle(
    fontFamily: 'Poppins', fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  // ── Screen / AppBar titles ────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Poppins', fontSize: 20,
    fontWeight: FontWeight.bold, color: AppColors.textWhite,
  );
  static const TextStyle screenTitle = TextStyle(
    fontFamily: 'Poppins', fontSize: 24,
    fontWeight: FontWeight.bold, color: AppColors.textWhite,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Poppins', fontSize: 18,
    fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.bold, color: Colors.grey,
    letterSpacing: 0.5,
  );

  // ── Body (Inter) ──────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter', fontSize: 16,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter', fontSize: 12,
    color: AppColors.textSecondary, height: 1.4,
  );

  // ── Labels ────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter', fontSize: 11,
    fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );

  // ── Captions / Hints ──────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter', fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const TextStyle hint = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    color: AppColors.textHint,
  );

  // ── Buttons ───────────────────────────────────────────────
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Poppins', fontSize: 16,
    fontWeight: FontWeight.w600, color: AppColors.textWhite,
    letterSpacing: 0.5,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.textWhite,
  );

  // ── Auth screen ───────────────────────────────────────────
  static const TextStyle brandName = TextStyle(
    color: AppColors.textWhite, fontSize: 36,
    fontWeight: FontWeight.bold, letterSpacing: 2,
  );
  static const TextStyle authSubtitle = TextStyle(
    color: AppColors.textWhite, fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle authCaption = TextStyle(
    color: Color(0xCCFFFFFF), fontSize: 14,
  );

  // ── Form fields ───────────────────────────────────────────
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle fieldValue = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    color: AppColors.textPrimary,
  );

  // ── Misc ──────────────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontFamily: 'Inter', fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle price = TextStyle(
    fontFamily: 'Inter', fontSize: 14,
    fontWeight: FontWeight.w600, color: AppColors.error,
  );
  static const TextStyle link = TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.w600, color: AppColors.primaryBlue,
  );
}