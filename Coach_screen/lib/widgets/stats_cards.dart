import 'package:flutter/material.dart';
import 'package:maranny32/theme/app_color.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});
 Widget _item(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Row(
        children: [
          _item(Icons.calendar_today, "2", "Today"),
          _item(Icons.attach_money, "\$450", "This week"),
          _item(Icons.people, "28", "Clients"),
          _item(Icons.star, "4.9", "Rating"),
        ],
      ),
    );
  }
}