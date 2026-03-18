import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SessionCard extends StatelessWidget {
  final String name;
  final String sport;
  final String time;
  final String location;
  final String status;

  const SessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.time,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = status == 'Confirmed';
    final Color statusColor = isConfirmed ? AppColors.confirmed : AppColors.pending;
    final Color statusBgColor = isConfirmed ? AppColors.confirmedLight : AppColors.pendingLight;

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
                // Sport
                Text(
                  sport,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Time with icon
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Location with icon
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
