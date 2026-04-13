import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// APP SPACING — consistent spacing scale
/// Usage:  SizedBox(height: AppSpacing.md)
///         Padding(padding: EdgeInsets.all(AppSpacing.md))
/// ─────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // ── Padding shortcuts ─────────────────────────────────────
  static const EdgeInsets screenPadding =
  EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets cardPadding =
  EdgeInsets.all(md);
  static const EdgeInsets sectionPadding =
  EdgeInsets.fromLTRB(md, md, md, sm);
  static const EdgeInsets listItemPadding =
  EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets buttonPadding =
  EdgeInsets.symmetric(vertical: 14);
  static const EdgeInsets inputPadding =
  EdgeInsets.symmetric(horizontal: 16, vertical: 14);
}

/// ─────────────────────────────────────────────────────────────
/// APP RADIUS — consistent border radii
/// Usage:  BorderRadius.circular(AppRadius.card)
/// ─────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double card = 13.0;
  static const double full = 100.0;

  static BorderRadius get cardRadius =>
      BorderRadius.circular(card);
  static BorderRadius get buttonRadius =>
      BorderRadius.circular(md);
  static BorderRadius get inputRadius =>
      BorderRadius.circular(md);
  static BorderRadius get sheetRadius =>
      const BorderRadius.vertical(top: Radius.circular(xxl));
  static BorderRadius get chipRadius =>
      BorderRadius.circular(full);
}

/// ─────────────────────────────────────────────────────────────
/// APP SHADOWS — reusable box shadows
/// Usage:  BoxDecoration(boxShadow: AppShadows.card)
/// ─────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 15,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> bottomBar = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, -2),
    ),
  ];
}