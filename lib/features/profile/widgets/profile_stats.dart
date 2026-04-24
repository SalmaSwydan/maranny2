import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final String totalBooked;
  final String totalSessions;
  final String hoursTrained;

  const ProfileStats({
    super.key,
    this.totalBooked = '0',
    this.totalSessions = '0',
    this.hoursTrained = '0',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatCard(
            icon: Icons.people,
            value: totalBooked,
            label: 'Total Booked',
          ),
          _StatCard(
            icon: Icons.track_changes,
            value: totalSessions,
            label: 'Total Sessions',
          ),
          _StatCard(
            icon: Icons.timer,
            value: hoursTrained,
            label: 'Hours Trained',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}