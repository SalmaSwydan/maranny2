import 'package:flutter/material.dart';

class WhyMarannySection extends StatelessWidget {
  const WhyMarannySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Why MARANNY ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            _WhyItem(
              icon: Icons.verified,
              iconColor: Colors.green,
              title: 'Trusted Coaches',
              description:
              'Coaches with strong profiles and community trust',
            ),

            _WhyItem(
              icon: Icons.star,
              iconColor: Colors.blue,
              title: 'User Reviews',
              description:
              'Feedback shared by users after their sessions',
            ),

            _WhyItem(
              icon: Icons.location_on,
              iconColor: Colors.pink,
              title: 'Location-Based',
              description:
              'Find coaches and facilities near you',
            ),

            _WhyItem(
              icon: Icons.auto_awesome,
              iconColor: Colors.indigo,
              title: 'AI Recommendations',
              description:
              'Personalized coach suggestions based on your goals',
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class _WhyItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _WhyItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
