import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SessionCard extends StatelessWidget {
  final String name;
  final String sport;
  final String time;
  final String location;
  final String status;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.time,
    required this.location,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: AppColors.deepBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$sport with $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF38607A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.deepBlue.withValues(alpha: 0.95),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
