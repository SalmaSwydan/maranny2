import 'package:flutter/material.dart';
import '../features/home/presentation/screens/client_homescreen.dart';
import '../features/bookings/presentation/screens/booking_screen.dart';
import '../features/home/presentation/screens/client_search_screen.dart';
import '../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../features/messages/presentation/screens/messages_screen.dart';
import '../features/profile/presentation/screens/client_profile.dart';
import '../features/messages/data/repositories/messages_repository.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final MessagesRepository _messagesRepository = MessagesRepository();
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadMessages();
  }

  Future<void> _loadUnreadMessages() async {
    try {
      final count = await _messagesRepository.getUnreadCount();
      if (mounted) {
        setState(() => _unreadMessages = count);
      }
    } catch (_) {}
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 3) {
            setState(() => _unreadMessages = 0);
          } else {
            _loadUnreadMessages();
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: _ChatNavIcon(count: _unreadMessages),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatNavIcon extends StatelessWidget {
  final int count;

  const _ChatNavIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.chat),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
