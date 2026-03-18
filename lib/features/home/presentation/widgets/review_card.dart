import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  final String timestamp;
  final int rating; // Rating out of 5

  const ReviewCard({
    super.key,
    required this.name,
    required this.review,
    required this.timestamp,
    this.rating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Review text
                Text(
                  review,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Stars rating
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 16,
                color: index < rating ? Colors.amber : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
