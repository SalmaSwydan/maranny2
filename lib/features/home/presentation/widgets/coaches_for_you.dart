import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../../home/presentation/screens/ai_recommended_coaches_screen.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class CoachesForYouSection extends StatefulWidget {
  const CoachesForYouSection({super.key});

  @override
  State<CoachesForYouSection> createState() => _CoachesForYouSectionState();
}

class _CoachesForYouSectionState extends State<CoachesForYouSection> {
  final ProfileRepository _profileRepository = ProfileRepository();
  late Future<List<_CoachPreview>> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = _loadPreviewCoaches();
  }

  Future<List<_CoachPreview>> _loadPreviewCoaches() async {
    UserPreferences preferences;
    try {
      preferences = await _profileRepository.getPreferences();
      await UserPreferencesStorage.saveSnapshot(preferences);
    } catch (_) {
      preferences = await UserPreferencesStorage.load();
    }

    if (preferences.sports.isEmpty) {
      return const <_CoachPreview>[];
    }

    final results = await Future.wait<dynamic>([
      _profileRepository.searchCoachesList(
        page: 1,
        pageSize: 40,
        sortBy: 'rating',
        sortOrder: 'desc',
      ),
    ]);

    final coaches = List<Map<String, dynamic>>.from(results[0] as List);
    final preferredSportCoaches = coaches
        .where((coach) => _matchesPreferredSports(coach, preferences.sports))
        .toList(growable: false);

    final ranked =
        preferredSportCoaches
            .map((coach) => _CoachPreview.fromJson(coach, preferences))
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return ranked.take(5).toList(growable: false);
  }

  Future<void> _openRecommendations() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiRecommendedCoachesScreen()),
    );
    if (!mounted) return;
    setState(() {
      _previewFuture = _loadPreviewCoaches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openRecommendations,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            gradient: AppColors.authGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(onViewAll: _openRecommendations),
              const SizedBox(height: 16),
              FutureBuilder<List<_CoachPreview>>(
                future: _previewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _PreviewLoading();
                  }

                  if (snapshot.hasError) {
                    return const _PreviewMessage(
                      icon: Icons.wifi_off_rounded,
                      title: 'Recommendations are loading soon',
                      subtitle: 'Tap to open the full coach list.',
                    );
                  }

                  final coaches = snapshot.data ?? const <_CoachPreview>[];
                  if (coaches.isEmpty) {
                    return const _PreviewMessage(
                      icon: Icons.sports_soccer_rounded,
                      title: 'Choose your preferred sports',
                      subtitle: 'Save sports interests to see matched coaches.',
                    );
                  }

                  return _CoachPreviewList(coaches: coaches);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Recommended Coaches For You',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.deepBlue,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachPreviewList extends StatelessWidget {
  const _CoachPreviewList({required this.coaches});

  final List<_CoachPreview> coaches;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          _OverlappingAvatars(coaches: coaches),
          const SizedBox(height: 12),
          ...coaches
              .take(3)
              .map(
                (coach) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CoachPreviewRow(coach: coach),
                ),
              ),
          if (coaches.length > 3)
            Text(
              '+${coaches.length - 3} more strong matches',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlappingAvatars extends StatelessWidget {
  const _OverlappingAvatars({required this.coaches});

  final List<_CoachPreview> coaches;

  @override
  Widget build(BuildContext context) {
    final visible = coaches.take(5).toList(growable: false);

    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          for (var index = 0; index < visible.length; index++)
            Positioned(
              left: index * 34,
              child: _CoachAvatar(coach: visible[index], radius: 24),
            ),
        ],
      ),
    );
  }
}

class _CoachPreviewRow extends StatelessWidget {
  const _CoachPreviewRow({required this.coach});

  final _CoachPreview coach;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _CoachAvatar(coach: coach, radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coach.sport,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6C7897),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RatingPill(rating: coach.rating),
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar({required this.coach, required this.radius});

  final _CoachPreview coach;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = coach.name.trim().isEmpty
        ? 'C'
        : coach.name.trim()[0].toUpperCase();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: coach.imageUrl.isEmpty
            ? ColoredBox(
                color: const Color(0xFFEAF0FB),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: radius * 0.78,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            : Image.network(
                coach.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: const Color(0xFFEAF0FB),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: radius * 0.78,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.deepBlue, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white.withValues(alpha: 0.9),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachPreview {
  const _CoachPreview({
    required this.name,
    required this.sport,
    required this.imageUrl,
    required this.rating,
    required this.score,
  });

  final String name;
  final String sport;
  final String imageUrl;
  final double rating;
  final double score;

  factory _CoachPreview.fromJson(
    Map<String, dynamic> coach,
    UserPreferences prefs,
  ) {
    final sports = _coachSportNames(coach);
    final sport = sports.isNotEmpty
        ? sports.first
        : _firstText([coach['sport'], coach['sportName']], fallback: 'Coach');
    final locations = _coachLocations(coach);
    final price = _coachPrice(coach);
    final rating = _coachRating(coach);
    final availableDays = _stringList(coach['availableDays']);

    final sportMatch =
        prefs.sports.isEmpty ||
        prefs.sports.any(
          (pref) => sports.any(
            (coachSport) =>
                coachSport.toLowerCase().trim() == pref.toLowerCase().trim(),
          ),
        );
    final locationMatch = _locationMatches(locations, prefs);
    final priceMatch =
        prefs.budgetMax == null ||
        price == 0 ||
        price <= prefs.budgetMax!.round();
    final ratingMatch = prefs.minRating == null || rating >= prefs.minRating!;
    final timeMatch = availableDays.isNotEmpty || _hasUpcomingSlots(coach);
    final genderMatch = _genderMatches(coach, prefs);

    var score = 40.0;
    if (sportMatch) score += 18;
    if (locationMatch) score += 16;
    if (priceMatch) score += 14;
    if (ratingMatch) score += 8;
    if (timeMatch) score += 8;
    if (genderMatch) score += 6;
    if (rating >= 4.5) score += 4;
    score = score.clamp(45, 99);

    return _CoachPreview(
      name: _firstText([
        coach['name'],
        coach['coachName'],
        coach['fullName'],
        coach['user'] is Map ? (coach['user'] as Map)['name'] : null,
      ], fallback: 'Coach'),
      sport: sport,
      imageUrl: _coachImage(coach),
      rating: rating,
      score: score,
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

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}

List<String> _coachSportNames(Map<String, dynamic> coach) {
  final names = <String>[];
  final sports = coach['sports'];
  if (sports is List) {
    for (final sport in sports) {
      if (sport is Map) {
        final name = _firstText([sport['name'], sport['sportName']]);
        if (name.isNotEmpty) names.add(name);
      } else {
        final name = sport.toString().trim();
        if (name.isNotEmpty) names.add(name);
      }
    }
  }
  final direct = _firstText([coach['sport'], coach['sportName']]);
  if (direct.isNotEmpty) names.add(direct);
  return names.toSet().toList(growable: false);
}

bool _matchesPreferredSports(
  Map<String, dynamic> coach,
  List<String> preferredSports,
) {
  final preferred = preferredSports
      .map((sport) => sport.trim().toLowerCase())
      .where((sport) => sport.isNotEmpty)
      .toSet();
  if (preferred.isEmpty) return false;

  final coachSports = _coachSportNames(coach)
      .map((sport) => sport.trim().toLowerCase())
      .where((sport) => sport.isNotEmpty);

  return coachSports.any(preferred.contains);
}

List<String> _coachLocations(Map<String, dynamic> coach) {
  final values = <String>[];
  void add(dynamic raw) {
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return;
    for (final part
        in text.replaceAll('[', '').replaceAll(']', '').split(',')) {
      final cleaned = part.trim();
      if (cleaned.isNotEmpty && !values.contains(cleaned)) {
        values.add(cleaned);
      }
    }
  }

  final locations = coach['locations'] ?? coach['Locations'];
  if (locations is List) {
    for (final location in locations) {
      add(location);
    }
  }
  add(coach['area']);
  add(coach['city']);
  add(coach['location']);
  return values;
}

bool _locationMatches(List<String> locations, UserPreferences prefs) {
  final preferred = <String>[
    if ((prefs.area ?? '').trim().isNotEmpty) prefs.area!.trim(),
    if ((prefs.city ?? '').trim().isNotEmpty) prefs.city!.trim(),
  ];
  if (preferred.isEmpty) return true;
  return locations.any((location) {
    final cleanLocation = location.toLowerCase();
    return preferred.any(
      (pref) =>
          cleanLocation.contains(pref.toLowerCase()) ||
          pref.toLowerCase().contains(cleanLocation),
    );
  });
}

bool _hasUpcomingSlots(Map<String, dynamic> coach) {
  final upcoming = coach['upcomingAvailableDates'];
  return upcoming is List && upcoming.isNotEmpty;
}

bool _genderMatches(Map<String, dynamic> coach, UserPreferences prefs) {
  final preferred = (prefs.coachGender ?? '').trim().toLowerCase();
  if (preferred.isEmpty ||
      preferred == 'any' ||
      preferred == 'no preference' ||
      preferred == 'all') {
    return true;
  }

  final gender = _firstText([
    coach['gender'],
    coach['coachGender'],
    coach['user'] is Map ? (coach['user'] as Map)['gender'] : null,
  ]).toLowerCase();
  return gender.isEmpty || gender == preferred;
}

double _coachRating(Map<String, dynamic> coach) {
  final value = coach['avgRating'] ?? coach['rating'] ?? coach['averageRating'];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _coachPrice(Map<String, dynamic> coach) {
  final sports = coach['sports'];
  if (sports is List && sports.isNotEmpty && sports.first is Map) {
    final value = (sports.first as Map)['pricePerSession'];
    if (value is num) return value.round();
  }
  final value =
      coach['startingPrice'] ?? coach['price'] ?? coach['pricePerSession'];
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _coachImage(Map<String, dynamic> coach) {
  final user = coach['user'];
  final raw = _firstText([
    coach['profilePictureUrl'],
    coach['profilePictureURL'],
    coach['profilePicture'],
    coach['profileImageUrl'],
    coach['profileImageURL'],
    coach['imageUrl'],
    coach['imageURL'],
    coach['image'],
    coach['photoUrl'],
    coach['photoURL'],
    coach['photo'],
    coach['avatar'],
    coach['avatarUrl'],
    coach['url'],
    if (user is Map) user['profilePictureUrl'],
    if (user is Map) user['profilePictureURL'],
    if (user is Map) user['profilePicture'],
    if (user is Map) user['profileImageUrl'],
    if (user is Map) user['imageUrl'],
  ]);
  return ApiConfig.resolveMediaUrl(raw);
}
