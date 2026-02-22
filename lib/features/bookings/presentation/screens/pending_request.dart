import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';
import '../../../profile/presentation/screens/coach_profile_screen.dart';
import '../../../home/presentation/screens/coach_homescreen.dart';
import '../../../marketplace/presentation/screens/marketplace_screen.dart';
import '../../../messages/presentation/screens/messages_clients.dart';

class PendingRequestScreen extends StatelessWidget {
  const PendingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: CoachBottomNav(
        initialIndex: 1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => CoachHomeScreen(onAuthRequired: () {}),
              ),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MarketplaceScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MessagesClientsScreen(),
              ),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CoachProfileScreen(),
              ),
            );
          }
        },
      ),
      body: const SafeArea(
        child: SizedBox(),
      ),
    );
  }
}

