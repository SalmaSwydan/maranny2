import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/ai_recommended_coaches_screen.dart';

class CoachesForYouSection extends StatelessWidget {
  const CoachesForYouSection({super.key});

  void _openRecommendations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiRecommendedCoachesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openRecommendations(context),
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            gradient: AppColors.authGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI coach recommendations',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.deepBlue,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Open your ranked coach matches based on your saved sports, area, budget, rating, gender, age, and certification preferences.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
