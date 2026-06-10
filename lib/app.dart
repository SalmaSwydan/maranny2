import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class MarannyApp extends StatelessWidget {
  const MarannyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANNY',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
      home: const SplashScreen(),
    );
  }
}