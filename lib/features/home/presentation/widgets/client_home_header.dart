import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'search_bar.dart';
import 'client_sports_categories.dart';
import '../../../notifications/presentation/screens/client_notifications_screen.dart';
import '../screens/client_search_screen.dart';

class HomeHeaderTwo extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String userName;

  const HomeHeaderTwo({super.key, this.onMenuTap, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeRow(onMenuTap: onMenuTap, userName: userName),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientSearchScreen()),
            ),
            child: const AbsorbPointer(child: HomeSearchBar()),
          ),
          const SizedBox(height: 18),
          const SportsCategoriesTwo(),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome back, $firstName!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'find coaches, book sessions, and track your progress',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ClientNotificationsScreen(),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
