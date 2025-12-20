import 'package:flutter/material.dart';

class FacilitiesCard extends StatelessWidget {
  const FacilitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
     return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: navigate to map screen
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // أزرق فاتح جدًا
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 28,
                color: Color(0xFF2563EB), // لون الثيم
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Find Sports Facilities",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap to view nearby gyms, courts & studios",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}