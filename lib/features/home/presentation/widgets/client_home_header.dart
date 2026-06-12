import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'search_bar.dart';
import '../../../notifications/presentation/screens/client_notifications_screen.dart';
import '../screens/client_search_screen.dart';

class HomeHeaderTwo extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String userName;

  const HomeHeaderTwo({super.key, this.onMenuTap, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 44, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeRow(onMenuTap: onMenuTap, userName: userName),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientSearchScreen()),
            ),
            child: const AbsorbPointer(child: HomeSearchBar()),
          ),
        ],
      ),
    );
  }
}

class _WelcomeRow extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String userName;

  const _WelcomeRow({this.onMenuTap, required this.userName});

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().isEmpty
        ? 'there'
        : userName.trim().split(' ').first;

    return Row(
      children: [
        GestureDetector(
          onTap: onMenuTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7E0F2)),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: AppColors.deepBlue,
              size: 19,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAIRO  -  24 C  -  CLEAR',
                style: TextStyle(
                  color: Color(0xFF9AA9C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hey $firstName.',
                style: const TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ClientNotificationsScreen(),
            ),
          ),
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
        ),
      ],
    );
  }
}
