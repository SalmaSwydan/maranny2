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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF122D86),
            Color(0xFF6FD3F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const _TopRow(),
          const SizedBox(height: 16),
          const _WelcomeText(),
          const SizedBox(height: 16),
          const _SearchBar(),
          const SizedBox(height: 16),

          /// 👇 Sports Categories تحت الـ Search
          _SportsCategories(onTap: onCategoryTap),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Icon(Icons.arrow_back_ios_new, color: Colors.white),
        Icon(Icons.notifications_none, color: Colors.white),
      ],
    );
  }
}

// --------------------------------------------------

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome to MARANNY!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Browse verified coaches and book your first session',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Browse coaches by name',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: null, // Guest only
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class _SportsCategories extends StatelessWidget {
  final VoidCallback onTap;

  const _SportsCategories({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem('All Sports', Icons.apps),
      _CategoryItem('Football', Icons.sports_soccer),
      _CategoryItem('Basketball', Icons.sports_basketball),
      _CategoryItem('Tennis', Icons.sports_tennis),
      _CategoryItem('Swimming', Icons.pool),
      _CategoryItem('Running', Icons.directions_run),
      _CategoryItem('Yoga', Icons.self_improvement),
      _CategoryItem('Boxing', Icons.sports_mma),
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
          color: Colors.white.withOpacity(0.2),
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
