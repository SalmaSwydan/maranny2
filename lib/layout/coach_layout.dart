import 'package:flutter/material.dart';

import '../features/home/presentation/screens/coach_homescreen.dart';
import '../features/bookings/presentation/screens/upcoming_pending.dart';
import '../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../features/messages/presentation/screens/messages_clients.dart';
import '../features/profile/presentation/screens/coach_profile_screen.dart';
import '../features/home/presentation/widgets/bottom_navigation.dart';

/// Main layout for COACH with persistent bottom navigation
/// Keeps all screens in memory using IndexedStack
class CoachMainLayout extends StatefulWidget {
  final int initialIndex;

  const CoachMainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<CoachMainLayout> createState() => _CoachMainLayoutState();
}

class _CoachMainLayoutState extends State<CoachMainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  late final List<Widget> _screens = [
    CoachHomeScreen(onAuthRequired: () {}),  // index 0 - Home
    const UpcomingScreen(),                  // index 1 - Bookings
    const MarketplaceScreen(),               // index 2 - Marketplace
    const MessagesClientsScreen(),           // index 3 - Messages
    const CoachProfileScreen(),              // index 4 - Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CoachBottomNav(
        initialIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}