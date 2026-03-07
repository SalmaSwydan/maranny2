import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// الاسم + الايموجي
            Text(
              '👤 ${widget.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '🏀 ${widget.sport}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            /// التاريخ والوقت
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

            /// الأزرار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isMessageSelected ? Colors.blue : Colors.white,
                      foregroundColor:
                      isMessageSelected ? Colors.white : Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isMessageSelected = true;
                      });

                      /// بعدين نفتح messages
                    },
                    child: const Text('💬 Message Coach'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      !isMessageSelected ? Colors.blue : Colors.white,
                      foregroundColor:
                      !isMessageSelected ? Colors.white : Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isMessageSelected = false;
                      });

                      /// بعدين نفتح profile
                    },
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
