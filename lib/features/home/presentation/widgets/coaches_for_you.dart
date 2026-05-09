import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/client_search_screen.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class CoachesForYouSection extends StatefulWidget {
  const CoachesForYouSection({super.key});

  @override
  State<CoachesForYouSection> createState() => _CoachesForYouSectionState();
}

class _CoachesForYouSectionState extends State<CoachesForYouSection> {
  final ProfileRepository _profileRepository = ProfileRepository();
  late final Future<List<Map<String, dynamic>>> _coachesFuture;

  @override
  void initState() {
    super.initState();
    _coachesFuture = _profileRepository.searchCoachesList(
      page: 1,
      pageSize: 6,
      sortBy: 'rating',
      sortOrder: 'desc',
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Coaches for you',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _openSearch,
              child: const Text(
                'see more ->',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _coachesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _CoachEmptyState(
                icon: Icons.wifi_off_outlined,
                title: 'Could not load coaches',
                message: 'Please try again from the search page.',
                onTap: _openSearch,
              );
            }

            final coaches = snapshot.data ?? const <Map<String, dynamic>>[];
            if (coaches.isEmpty) {
              return _CoachEmptyState(
                icon: Icons.person_search_outlined,
                title: 'No coaches available yet',
                message: 'Check back soon or explore all coaches.',
                onTap: _openSearch,
              );
            }

            return SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coaches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _CoachCard(coach: coaches[index], onTap: _openSearch);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  final VoidCallback onTap;

  const _CoachCard({required this.coach, required this.onTap});

  String get _name {
    return _firstText([
      coach['name'],
      coach['fullName'],
      coach['coachName'],
      coach['user'] is Map ? (coach['user'] as Map)['name'] : null,
    ], fallback: 'Coach');
  }

  String get _sport {
    final sports = coach['sports'];
    if (sports is List && sports.isNotEmpty) {
      final first = sports.first;
      if (first is Map) {
        return _firstText([
          first['name'],
          first['sportName'],
        ], fallback: 'Coach');
      }
      return first.toString();
    }

    return _firstText([coach['sport'], coach['sportName']], fallback: 'Coach');
  }

  String get _imageUrl {
    final raw = _firstText([
      coach['profilePictureUrl'],
      coach['profilePicture'],
      coach['imageUrl'],
      coach['photoUrl'],
      coach['avatar'],
    ]);
    return ApiConfig.resolveMediaUrl(raw);
  }

  double get _rating {
    final value =
        coach['avgRating'] ?? coach['rating'] ?? coach['averageRating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int get _reviews {
    final value =
        coach['totalReviews'] ?? coach['reviewsCount'] ?? coach['reviewCount'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  num? get _price {
    final value =
        coach['pricePerSession'] ?? coach['sessionPrice'] ?? coach['price'];
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoachImage(imageUrl: _imageUrl, name: _name),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sport,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_rating.toStringAsFixed(1)} ($_reviews reviews)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _price == null
                        ? 'Price not set'
                        : '${_price!.round()} LE/hr',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachImage extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _CoachImage({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: imageUrl.isEmpty
            ? Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CoachEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;

  const _CoachEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Explore')),
        ],
      ),
    );
  }
}

String _firstText(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return fallback;
}
