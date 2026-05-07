import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onCategoryTap;

  const HomeHeader({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 24, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF122D86), Color(0xFF6FD3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome text — centered, no back button, no bell
          const Text(
            'welcome to MARANNY!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse verified coaches and book your first session',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          // Sports categories
          _SportsCategories(onTap: onCategoryTap),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class _SportsCategories extends StatelessWidget {
  final VoidCallback onTap;
  const _SportsCategories({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem('All Sports', Icons.apps),
      _CategoryItem('Basketball', Icons.sports_basketball),
      _CategoryItem('Football', Icons.sports_soccer),
      _CategoryItem('Gym Training', Icons.fitness_center),
      _CategoryItem('Padel', Icons.sports_tennis),
      _CategoryItem('Swimming', Icons.pool),
      _CategoryItem('Tennis', Icons.sports_tennis),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sports Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
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
    );
  }
}

// --------------------------------------------------

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
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}
