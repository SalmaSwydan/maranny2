import 'package:flutter/material.dart';
import '../features/home/presentation/screens/client_homescreen.dart';
import '../features/bookings/presentation/screens/booking_screen.dart';
import '../features/home/presentation/screens/client_search_screen.dart';
import '../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../features/messages/presentation/screens/messages_screen.dart';
import '../features/profile/presentation/screens/client_profile.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
