import 'package:flutter/material.dart';

class SportsCategories extends StatelessWidget {
  final VoidCallback onTap;

  const SportsCategories({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem(label: 'All Sports', icon: Icons.apps),
      _CategoryItem(label: 'Basketball', icon: Icons.sports_basketball),
      _CategoryItem(label: 'Football', icon: Icons.sports_soccer),
      _CategoryItem(label: 'Gym Training', icon: Icons.fitness_center),
      _CategoryItem(label: 'Padel', icon: Icons.sports_tennis),
      _CategoryItem(label: 'Swimming', icon: Icons.pool),
      _CategoryItem(label: 'Tennis', icon: Icons.sports_tennis),
    ];


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sports Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = categories[index];
                return _CategoryChip(
                  label: item.label,
                  icon: item.icon,
                  onTap: onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem({
    required this.label,
    required this.icon,
  });
}

