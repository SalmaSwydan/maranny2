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

  static const List<_NavItemData> _items = [
    _NavItemData(Icons.home_outlined, 'Home'),
    _NavItemData(Icons.calendar_today_outlined, 'Bookings'),
    _NavItemData(Icons.storefront_outlined, 'Shop'),
    _NavItemData(Icons.chat_bubble_outline_rounded, 'Messages'),
    _NavItemData(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _loadUnreadMessages();
  }

  @override
  void didUpdateWidget(covariant CoachBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      currentIndex = widget.initialIndex;
    }
  }

  Future<void> _loadUnreadMessages() async {
    try {
      final count = await _messagesRepository.getUnreadCount();
      if (mounted) {
        setState(() => _unreadMessages = count);
      }
    } catch (_) {}
  }

  void _selectItem(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFDCE4F2))),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    item: _items[i],
                    active: i == currentIndex,
                    unreadCount: i == 3 ? _unreadMessages : 0,
                    onTap: () => _selectItem(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData(this.icon, this.label);
}

class _BottomNavItem extends StatelessWidget {
  final _NavItemData item;
  final bool active;
  final int unreadCount;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.active,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryBlue : const Color(0xFF51617F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon, color: color, size: 23),
                if (unreadCount > 0)
                  Positioned(
                    right: -9,
                    top: -7,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17),
                      height: 17,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF67D7EF),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Color(0xFF14326D),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 4 : 0,
              height: active ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
