import 'package:flutter/material.dart';
import '../features/home/presentation/screens/client_homescreen.dart';
import '../features/bookings/presentation/screens/booking_screen.dart';
import '../features/home/presentation/screens/client_search_screen.dart';
import '../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../features/messages/presentation/screens/messages_screen.dart';
import '../features/profile/presentation/screens/client_profile.dart';
import '../features/home/presentation/widgets/bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ClientHomeScreen(
            onGoToBookings: () => setState(() => _currentIndex = 1),
          ),
          BookingsScreen(
            onMessageTap: () => setState(() => _currentIndex = 3),
            // ✅ FIX: push SearchScreen using context from build method
            onBookAnotherCoach: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientSearchScreen()),
            ),
          ),
          const MarketplaceScreen(),
          const MessagesScreen(),
          const ClientProfileScreen(),
        ],
      ),
      bottomNavigationBar: CoachBottomNav(
        initialIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
