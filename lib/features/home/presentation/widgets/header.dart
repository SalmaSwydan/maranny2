import 'package:flutter/material.dart';
import 'coach_stat_card.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class CoachHomeHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const CoachHomeHeader({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF6FD3F5), Color(0xFF1F3A93)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 22),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                )),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('welcome back, Ahmed!',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 24,
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('you have 2 sessions scheduled today',
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatCard(icon: Icons.calendar_today, value: '2', label: 'Today'),
              // ✅ calendar icon instead of dollar sign
              StatCard(icon: Icons.bar_chart, value: '450 LE', label: 'This week'),
              StatCard(icon: Icons.people, value: '28', label: 'Clients'),
              StatCard(icon: Icons.star, value: '4.9', label: 'Rating'),
            ],
          ),
        ],
      ),
    );
  }
}
