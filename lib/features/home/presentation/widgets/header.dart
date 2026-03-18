import 'package:flutter/material.dart';
import 'coach_stat_card.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class CoachHomeHeader extends StatelessWidget {
  const CoachHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF6FD3F5), // light blue
            Color(0xFF1F3A93), // deep blue
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar and notification bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar with 'A'
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Color(0xFF1F3A93), // Dark blue for better contrast
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              // Notification bell with red dot
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Welcome message
          const Text(
            'welcome back, Ahmed!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          // Sessions info
          Text(
            'you have 2 sessions scheduled today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          // Stat cards row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatCard(
                icon: Icons.calendar_today,
                value: '2',
                label: 'Today',
              ),
              StatCard(
                icon: Icons.attach_money,
                value: '\$450',
                label: 'This week',
              ),
              StatCard(
                icon: Icons.people,
                value: '28',
                label: 'Clients',
              ),
              StatCard(
                icon: Icons.star,
                value: '4.9',
                label: 'Rating',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
