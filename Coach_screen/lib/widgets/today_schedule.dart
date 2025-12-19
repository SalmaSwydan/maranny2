import 'package:flutter/material.dart';
import 'package:maranny32/theme/app_color.dart';

class TodaySchedule extends StatelessWidget {
  const TodaySchedule({super.key});

  Widget _session(
      String name, String time, String court, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(
                  label: Text(status),
                  backgroundColor: status == "Confirmed"
                      ? AppColors.confirmed
                      : AppColors.pending,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Football"),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(time),
                const SizedBox(width: 12),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(court),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleLarge("Today's Schedule"),
          _session("Ahmed Mohamed", "10:00 AM - 11:00 AM", "Court 3",
              "Confirmed"),
          _session("Sarah Johnson", "2:00 AM - 3:00 AM", "Court 1",
              "Confirmed"),
          _session("Mike Chen", "4:00 AM - 5:00 AM", "Court 2",
              "Pending"),
        ],
      ),
    );
  }
  
  titleLarge(String t) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("View All →",
              style: TextStyle(color: Colors.blue[700])),
        ],
      );
}