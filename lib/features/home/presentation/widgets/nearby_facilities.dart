import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NearbySportsFacilitiesSection extends StatelessWidget {
  const NearbySportsFacilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Sports Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            // TODO: navigate to map screen later
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withOpacity(.1),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 30,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Find Sports Facilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap to view nearby gyms, courts & studios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
