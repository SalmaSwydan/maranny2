import 'package:flutter/material.dart';
import 'features/home/presentation/screens/guest_homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuestHomeScreen(
        onAuthRequired: () {
          debugPrint('Auth required');
        },
      ),
    );
  }
}
