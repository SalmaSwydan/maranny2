import 'package:flutter/material.dart';
import 'package:maranny_two/features/splash/presentation/screens/splash_screen.dart';

import 'features/profile/presentation/utils/coach_profile_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CoachProfileManager.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maranny',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F3A93)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/background_screen.png'),
                ),
              ),
            ),
            const SplashScreen(),
          ],
        ),
      ),
    );
  }
}
