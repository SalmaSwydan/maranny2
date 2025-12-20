import 'package:flutter/material.dart';

import 'facilities_card.dart';

class NearbyFacilitiesSection extends StatelessWidget {
  const NearbyFacilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nearby Sports Facilities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          FacilitiesCard(),
        ],
      ),
    );
  }
}