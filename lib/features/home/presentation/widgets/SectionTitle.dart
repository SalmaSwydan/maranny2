import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bookings/presentation/screens/upcoming_pending.dart';
import '../../../reviews/presentation/screens/all_reviews_screen.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to the bookings upcoming screen when tapping
              // "View All" for Today's Schedule.
              if (title == "Today's Schedule") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UpcomingScreen(),
                  ),
                );
              }
              // Navigate to bookings screen with Pending Requests tab when tapping
              // "View All" for Pending Requests.
              else if (title == "Pending Requests") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UpcomingScreen(initialTabIndex: 1),
                  ),
                );
              }
              // Navigate to All Reviews screen when tapping "View All" for Recent Reviews.
              else if (title == "Recent Reviews") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AllReviewsScreen(),
                  ),
                );
              }
            },
            child: const Text(
              'View All →',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
