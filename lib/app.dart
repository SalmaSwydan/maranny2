import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

/// ─────────────────────────────────────────────────────────────
/// MARANNY APP — root widget
///
/// Single source of truth for:
///   - Theme     → AppTheme.lightTheme
///   - Routes    → AppRouter.generateRoute
///   - Home      → SplashScreen (decides where to go)
/// ─────────────────────────────────────────────────────────────
class MarannyApp extends StatelessWidget {
  const MarannyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANNY',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────
      theme: AppTheme.lightTheme,

      // ── Router ──────────────────────────────────────────
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,

      // ── Home fallback (matches initialRoute) ────────────
      home: const SplashScreen(),
    );
  }
}