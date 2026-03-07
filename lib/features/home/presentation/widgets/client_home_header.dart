import 'package:flutter/material.dart';
import 'package:maranny_two/features/home/presentation/widgets/search_bar.dart';
import 'package:maranny_two/features/home/presentation/widgets/client_sports_categories.dart';
import '../../../../core/theme/app_colors.dart';
import 'sports_categories.dart';

class HomeHeaderTwo extends StatelessWidget {
  const HomeHeaderTwo({super.key});

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
        children: const [
          _WelcomeRow(),
          SizedBox(height: 20),
          HomeSearchBar(),
          SizedBox(height: 18),
          SportsCategoriesTwo(),
        ],
      ),
    );
  }
}

class _WelcomeRow extends StatelessWidget {
  const _WelcomeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          child: Text('A', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'welcome back, Ahmed!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'you have 2 sessions scheduled this week',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.notifications_none, color: Colors.white),
      ],
    );
  }
}
