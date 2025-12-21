import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class MarannyApp extends StatelessWidget {
  const MarannyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANNY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // or whatever you already have
    );
  }
}
