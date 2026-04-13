import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BookingSessionCard extends StatefulWidget {
  final String name;
  final String sport;
  final String date;
  final String time;

  const BookingSessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.date,
    required this.time,
  });

  @override
  State<BookingSessionCard> createState() => _BookingSessionCardState();
}

class _BookingSessionCardState extends State<BookingSessionCard> {
  bool isMessageSelected = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 ${widget.name}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('🏀 ${widget.sport}',
                style:
                const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(widget.date),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 6),
                Text(widget.time),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // ✅ AppColors
                      backgroundColor: isMessageSelected
                          ? AppColors.primaryBlue
                          : Colors.white,
                      foregroundColor: isMessageSelected
                          ? Colors.white
                          : AppColors.primaryBlue,
                      side: const BorderSide(
                          color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () =>
                        setState(() => isMessageSelected = true),
                    child: const Text('💬 Message Coach'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isMessageSelected
                          ? AppColors.primaryBlue
                          : Colors.white,
                      foregroundColor: !isMessageSelected
                          ? Colors.white
                          : AppColors.primaryBlue,
                      side: const BorderSide(
                          color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () =>
                        setState(() => isMessageSelected = false),
                    child: const Text('📄 Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}