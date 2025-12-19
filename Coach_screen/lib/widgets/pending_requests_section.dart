import 'package:flutter/material.dart';
import 'package:maranny32/theme/app_color.dart';

class PendingRequestsSection extends StatelessWidget {
  const PendingRequestsSection({super.key});

  Widget _request(String name, String time) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            Text("Football"),
            Text(time),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
  child: SizedBox(
    height: 44,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient, 
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          "Accept",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
  ),
),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    label: const Text("Decline"),
                  ),
                ),
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
          _title("Pending Requests"),
          _request("Zeyad Mohamed", "Dec 18 at 3:00 PM"),
          const SizedBox(height: 8),
          _request("Heba Ahmed", "Dec 20 at 10:00 AM"),
        ],
      ),
    );
  }

  Widget _title(String t) => Row(
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
