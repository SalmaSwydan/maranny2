import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UpcomingSessionsSection extends StatelessWidget {
  const UpcomingSessionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              UpcomingSessionCard(
                name: 'Ahmed mohamed',
                sport: 'Football',
                date: 'Tomorrow',
                time: '10:00 AM',
              ),
              UpcomingSessionCard(
                name: 'Sarah Ahmed',
                sport: 'Swimming',
                date: 'DEC 15',
                time: '2:00 PM',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Text(
          'Upcoming Sessions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          'view more →',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class UpcomingSessionCard extends StatelessWidget {
  final String name;
  final String sport;
  final String date;
  final String time;

  const UpcomingSessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sport,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(date),
              const SizedBox(width: 16),
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}
