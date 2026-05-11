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
    _coachesFuture = _loadRecommendedCoaches();
  }

  Future<List<Map<String, dynamic>>> _loadRecommendedCoaches() async {
    final coaches = await _profileRepository.searchCoachesList(
      page: 1,
      pageSize: 6,
      sortBy: 'rating',
      sortOrder: 'desc',
    );

    final recommended = coaches
        .take(6)
        .map((coach) => Map<String, dynamic>.from(coach))
        .toList();

    await Future.wait(
      recommended.map((coach) async {
        if (_rawCoachImage(coach).isNotEmpty) return;

        final coachId = _coachId(coach);
        if (coachId == null) return;

        try {
          final details = await _profileRepository.getCoachProfile(coachId);
          final imageUrl = details.profilePictureUrl?.trim() ?? '';
          if (imageUrl.isNotEmpty) {
            coach['profilePictureUrl'] = imageUrl;
          }
        } catch (_) {
          // The card still has a safe initials fallback if details are unavailable.
        }
      }),
    );

    return recommended;
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
              'For you',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _openSearch,
              child: const Text(
                'See all ->',
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: coaches.take(4).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) =>
                    _CoachCard(coach: coaches[index], onTap: _openSearch),
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
    return ApiConfig.resolveMediaUrl(_rawCoachImage(coach));
  }

  double get _rating {
    final value =
        coach['avgRating'] ?? coach['rating'] ?? coach['averageRating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  num? get _price {
    final value =
        coach['pricePerSession'] ??
        coach['sessionPrice'] ??
        coach['price'] ??
        _firstSportValue(['pricePerSession', 'sessionPrice', 'price']);
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CoachImage(
                imageUrl: _imageUrl,
                name: _name,
                sport: _sport,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFF6C7897),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_rating.toStringAsFixed(1)} - $_locationLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6C7897),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _price == null ? '' : '${_price!.round()}',
                        style: const TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _locationLabel {
    final locations = coach['locations'] ?? coach['Locations'];
    if (locations is List && locations.isNotEmpty) {
      return locations.first.toString().split(',').first.trim();
    }
    return _firstText([
      coach['city'],
      coach['location'],
      coach['area'],
      coach['coachLocation'],
    ], fallback: 'Nearby');
  }

  dynamic _firstSportValue(List<String> keys) {
    final sports = coach['sports'];
    if (sports is! List || sports.isEmpty || sports.first is! Map) return null;
    final firstSport = sports.first as Map;
    for (final key in keys) {
      final value = firstSport[key];
      if (value != null && value.toString().trim().isNotEmpty) return value;
    }
    return null;
  }
}

class _CoachImage extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String sport;

  const _CoachImage({
    required this.imageUrl,
    required this.name,
    required this.sport,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
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
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              sport.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
              ),
            ),
          ),
        ],
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

String _nestedText(dynamic source, List<String> keys) {
  if (source is! Map) return '';
  for (final key in keys) {
    final text = source[key]?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

int? _coachId(Map<String, dynamic> coach) {
  final value =
      coach['coachID'] ??
      coach['coachId'] ??
      coach['id'] ??
      coach['CoachID'] ??
      coach['CoachId'];
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _rawCoachImage(Map<String, dynamic> coach) {
  return _firstText([
    coach['profilePictureUrl'],
    coach['profilePictureURL'],
    coach['profileImageUrl'],
    coach['profileImageURL'],
    coach['profilePicture'],
    coach['pictureUrl'],
    coach['pictureURL'],
    coach['imageUrl'],
    coach['imageURL'],
    coach['image'],
    coach['photoUrl'],
    coach['photoURL'],
    coach['photo'],
    coach['avatar'],
    coach['avatarUrl'],
    coach['avatarURL'],
    coach['url'],
    _nestedText(coach['user'], [
      'profilePictureUrl',
      'profilePictureURL',
      'profileImageUrl',
      'profileImageURL',
      'profilePicture',
      'pictureUrl',
      'pictureURL',
      'imageUrl',
      'imageURL',
      'photoUrl',
      'photoURL',
      'avatarUrl',
      'avatarURL',
      'url',
    ]),
    _nestedText(coach['coach'], [
      'profilePictureUrl',
      'profilePictureURL',
      'profileImageUrl',
      'profileImageURL',
      'profilePicture',
      'pictureUrl',
      'pictureURL',
      'imageUrl',
      'imageURL',
      'photoUrl',
      'photoURL',
      'avatarUrl',
      'avatarURL',
      'url',
    ]),
  ]);
}
