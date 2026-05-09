import 'package:flutter/material.dart';
import 'coach_stat_card.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class CoachHomeHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String userName;
  final int todaySessionsCount;
  final int pendingRequestsCount;
  final int recentReviewsCount;
  final bool isVerified;

  const CoachHomeHeader({
    super.key,
    this.onMenuTap,
    required this.userName,
    this.todaySessionsCount = 0,
    this.pendingRequestsCount = 0,
    this.recentReviewsCount = 0,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final firstName = userName.trim().isEmpty
        ? 'Coach'
        : userName.trim().split(' ').first;

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 22),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
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
          Text(
            'welcome back, $firstName!',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            todaySessionsCount == 0
                ? 'no confirmed sessions scheduled today'
                : 'you have $todaySessionsCount confirmed session${todaySessionsCount == 1 ? '' : 's'} today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                icon: Icons.calendar_today,
                value: '$todaySessionsCount',
                label: 'Today',
              ),
              StatCard(
                icon: Icons.pending_actions,
                value: '$pendingRequestsCount',
                label: 'Pending',
              ),
              StatCard(
                icon: Icons.rate_review,
                value: '$recentReviewsCount',
                label: 'Reviews',
              ),
              StatCard(
                icon: Icons.verified,
                value: isVerified ? 'Yes' : 'No',
                label: 'Verified',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
