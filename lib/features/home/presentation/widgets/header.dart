import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      padding: EdgeInsets.fromLTRB(18, topPadding + 14, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderCircleButton(icon: Icons.menu_rounded, onTap: onMenuTap),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COACH DASHBOARD',
                      style: TextStyle(
                        color: Color(0xFF9AA9C6),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Hey $firstName.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              _NotificationButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            todaySessionsCount == 0
                ? 'No confirmed sessions scheduled today.'
                : '$todaySessionsCount confirmed session${todaySessionsCount == 1 ? '' : 's'} today.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C7897),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.calendar_today_rounded,
                  value: '$todaySessionsCount',
                  label: 'Today',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.pending_actions_rounded,
                  value: '$pendingRequestsCount',
                  label: 'Pending',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.star_border_rounded,
                  value: '$recentReviewsCount',
                  label: 'Reviews',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.verified_rounded,
                  value: isVerified ? 'Yes' : 'No',
                  label: 'Verified',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD7E0F2)),
        ),
        child: Icon(icon, color: AppColors.deepBlue, size: 19),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD7E0F2)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.deepBlue,
              size: 24,
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5A5F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
