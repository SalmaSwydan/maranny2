import 'package:flutter/material.dart';

class PendingRequestScreen extends StatelessWidget {
  const PendingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // ✅ NO bottomNavigationBar - handled by CoachMainLayout
      body: const SafeArea(
        child: Center(
          child: Text(
            'Pending Requests',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}