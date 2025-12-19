import 'package:flutter/material.dart';

class FeaturedCoachesSection extends StatelessWidget {
  final VoidCallback onSeeMore;

  const FeaturedCoachesSection({
    super.key,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final coaches = [
      _CoachItem(
        name: 'Ahmed Mohamed',
        sport: 'Football',
        rating: 4.9,
        reviews: 80,
        price: 25,
        emoji: '🧑‍🏫',
      ),
      _CoachItem(
        name: 'Sarah Ahmed',
        sport: 'Swimming',
        rating: 4.0,
        reviews: 77,
        price: 15,
        emoji: '👩‍🏫',
      ),
      _CoachItem(
        name: 'Ziad Marwan',
        sport: 'Padel',
        rating: 4.7,
        reviews: 16,
        price: 25,
        emoji: '🙋‍♂️',
      ),
      _CoachItem(
        name: 'Omar Khaled',
        sport: 'Fitness',
        rating: 4.8,
        reviews: 42,
        price: 20,
        emoji: '💪',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Title + See more
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Coaches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeMore,
                  child: const Text(
                    'see more →',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Coaches list
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: coaches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _CoachCard(
                  coach: coaches[index],
                  onTap: onSeeMore, // Guest behavior
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _CoachCard extends StatelessWidget {
  final _CoachItem coach;
  final VoidCallback onTap;

  const _CoachCard({
    required this.coach,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                coach.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              coach.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            Text(
              coach.sport,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${coach.rating} (${coach.reviews} reviews)',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),

            const Spacer(),

            Text(
              '\$${coach.price}/hr',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CoachItem {
  final String name;
  final String sport;
  final double rating;
  final int reviews;
  final int price;
  final String emoji;

  const _CoachItem({
    required this.name,
    required this.sport,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.emoji,
  });
}
