import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String name;
  final String sport;
  final String time;
  final String court;
  final String status; // Confirmed / Pending

  const ScheduleCard({
    super.key,
    required this.name,
    required this.sport,
    required this.time,
    required this.court,
    required this.status,
  });

  Color _pillBg() {
    if (status.toLowerCase().contains('confirm')) return const Color(0xFFD8FFE0);
    return const Color(0xFFFFF3C8);
  }

  Color _pillText() {
    if (status.toLowerCase().contains('confirm')) return const Color(0xFF2E7D32);
    return const Color(0xFF8D6E00);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _pillBg(),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: _pillText(),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sport,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: Colors.black87)),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(court, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
