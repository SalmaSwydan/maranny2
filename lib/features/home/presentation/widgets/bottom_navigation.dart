import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../messages/data/repositories/messages_repository.dart';

class CoachBottomNav extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onItemSelected;

  const CoachBottomNav({super.key, this.initialIndex = 0, this.onItemSelected});

  @override
  State<CoachBottomNav> createState() => _CoachBottomNavState();
}

class _CoachBottomNavState extends State<CoachBottomNav> {
  late int currentIndex;
  final MessagesRepository _messagesRepository = MessagesRepository();
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            if (index == 3) {
              _unreadMessages = 0;
            }
          });
          if (index != 3) {
            _loadUnreadMessages();
          }
          widget.onItemSelected?.call(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        iconSize: 24,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: _ChatNavIcon(count: _unreadMessages, active: false),
            activeIcon: _ChatNavIcon(count: _unreadMessages, active: true),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatNavIcon extends StatelessWidget {
  final int count;
  final bool active;

  const _ChatNavIcon({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.chat_bubble : Icons.chat_bubble_outline),
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
