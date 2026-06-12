import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cairo_time.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/domain/models/coach_data_model.dart';
import '../../../bookings/presentation/screens/coach_details_screen.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../sports/data/repositories/sports_repository.dart';

class AiRecommendedCoachesScreen extends StatefulWidget {
  const AiRecommendedCoachesScreen({super.key});

  @override
  State<AiRecommendedCoachesScreen> createState() =>
      _AiRecommendedCoachesScreenState();
}

class _AiRecommendedCoachesScreenState
    extends State<AiRecommendedCoachesScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final SportsRepository _sportsRepository = SportsRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  String _selectedSport = 'All';
  String _query = '';
  UserPreferences _preferences = const UserPreferences(sports: <String>[]);
  List<String> _sports = const [
    'All',
    'Football',
    'Basketball',
    'Padel',
    'Gym',
  ];
  List<_RecommendedCoach> _coaches = const [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _loadLatestPreferences(),
        _profileRepository.searchCoachesList(
          page: 1,
          pageSize: 40,
          sortBy: 'rating',
          sortOrder: 'desc',
        ),
        _sportsRepository.getSports(),
      ]);

      final prefs = results[0] as UserPreferences;
      final rawCoaches = List<Map<String, dynamic>>.from(results[1] as List);
      final apiSports = results[2] as List;

      final sports = <String>['All'];
      for (final sport in apiSports) {
        final name = sport.name.toString().trim();
        if (name.isNotEmpty && !sports.contains(name)) {
          sports.add(name);
        }
      }
      if (sports.length == 1) {
        sports.addAll(const ['Football', 'Basketball', 'Padel', 'Gym']);
      }

      final ranked =
          rawCoaches
              .map((coach) => _RecommendedCoach.fromJson(coach, prefs))
              .where((coach) => coach.isEligible)
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));

      if (!mounted) return;
      setState(() {
        _preferences = prefs;
        _sports = sports;
        _selectedSport = prefs.sports.isNotEmpty ? prefs.sports.first : 'All';
        if (!_sports.contains(_selectedSport)) {
          _selectedSport = 'All';
        }
        _coaches = ranked;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load recommendations right now.';
        _isLoading = false;
      });
    }
  }

  Future<UserPreferences> _loadLatestPreferences() async {
    try {
      final prefs = await _profileRepository.getPreferences();
      await UserPreferencesStorage.saveSnapshot(prefs);
      return prefs;
    } catch (_) {
      return UserPreferencesStorage.load();
    }
  }

  List<_RecommendedCoach> get _visibleCoaches {
    final normalizedQuery = _query.trim().toLowerCase();
    return _coaches
        .where((coach) {
          final matchesSport =
              _selectedSport == 'All' ||
              _textMatches(coach.sport, _selectedSport) ||
              coach.sports.any((sport) => _textMatches(sport, _selectedSport));

          if (!matchesSport) return false;
          if (normalizedQuery.isEmpty) return true;

          return coach.name.toLowerCase().contains(normalizedQuery) ||
              coach.sport.toLowerCase().contains(normalizedQuery) ||
              coach.location.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  void _openCoach(_RecommendedCoach coach) {
    final session = BookingSessionModel(
      id: coach.name.replaceAll(' ', '_'),
      coachUserId: coach.coachId,
      sportId: coach.sportId,
      coachName: coach.name,
      sport: coach.sport,
      location: coach.location,
      date: CairoTime.now(),
      isPast: false,
      isReviewed: false,
    );

    final coachData = CoachData(
      name: coach.name,
      sport: coach.sport,
      sportId: coach.sportId,
      location: coach.location,
      locations: coach.locations,
      image: coach.imageUrl,
      availableDays: coach.availableDays,
      rating: coach.rating,
      reviewCount: coach.reviewCount,
      price: coach.price,
      bio: coach.bio,
      totalStudents: coach.totalStudents,
      totalSessions: coach.totalSessions,
      hoursTaught: coach.hoursTaught,
      achievements: const [],
      reviews: const [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          session: session,
          image: coach.imageUrl,
          coachData: coachData,
        ),
      ),
    );
  }

  void _showHowItWorks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HowAiWorksSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleCoaches;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRecommendations,
                color: AppColors.deepBlue,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                  children: [
                    _TopHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 20),
                    const Text(
                      'AI recommended coaches',
                      style: TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 34,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ranked from your saved preferences and real coach data.',
                      style: TextStyle(
                        color: Color(0xFF6C7897),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 16),
                    _SportsFilter(
                      sports: _sports,
                      selected: _selectedSport,
                      onSelected: (sport) {
                        setState(() => _selectedSport = sport);
                      },
                    ),
                    const SizedBox(height: 14),
                    _PreferencesCard(preferences: _preferences),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _EmptyState(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Recommendations unavailable',
                        message: _error!,
                        buttonText: 'Try again',
                        onTap: _loadRecommendations,
                      )
                    else if (visible.isEmpty)
                      _EmptyState(
                        icon: Icons.person_search_rounded,
                        title: 'No matching coaches yet',
                        message:
                            'No coach currently matches your saved preferences. Try updating your preferences or another sport.',
                        buttonText: 'Reset',
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _selectedSport = 'All';
                          });
                        },
                      )
                    else
                      ...List.generate(visible.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _RecommendationCard(
                            coach: visible[index],
                            rank: index + 1,
                            onBook: () => _openCoach(visible[index]),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showHowItWorks,
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('How does it work?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.deepBlue.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FB),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD7E0F2)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.deepBlue,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E0F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search_rounded, color: Color(0xFF6C7897)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search coach or sport',
                hintStyle: TextStyle(
                  color: Color(0xFF8A96B3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.deepBlue),
          ),
        ],
      ),
    );
  }
}

class _SportsFilter extends StatelessWidget {
  const _SportsFilter({
    required this.sports,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sports;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isSelected = sport == selected;
          return ChoiceChip(
            label: Text(sport),
            selected: isSelected,
            onSelected: (_) => onSelected(sport),
            showCheckmark: false,
            selectedColor: AppColors.deepBlue,
            backgroundColor: const Color(0xFFEAF0FB),
            side: BorderSide(
              color: isSelected ? AppColors.deepBlue : const Color(0xFFD7E0F2),
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.preferences});

  final UserPreferences preferences;

  List<String> get _items {
    final items = <String>[];
    if (preferences.sports.isNotEmpty) {
      items.add('Sports: ${preferences.sports.join(', ')}');
    }
    final area = (preferences.area ?? '').trim();
    final city = (preferences.city ?? '').trim();
    if (area.isNotEmpty) {
      items.add('Area: $area');
    } else if (city.isNotEmpty) {
      items.add('City: $city');
    }
    if (preferences.budgetMin != null || preferences.budgetMax != null) {
      final min = preferences.budgetMin?.round();
      final max = preferences.budgetMax?.round();
      if (min != null && max != null) {
        items.add('Budget: $min-$max LE/hr');
      } else if (max != null) {
        items.add('Budget: <= $max LE/hr');
      } else if (min != null) {
        items.add('Budget: >= $min LE/hr');
      }
    }
    if (preferences.minRating != null) {
      items.add('Rating: ${preferences.minRating!.toStringAsFixed(1)}+');
    }
    final gender = (preferences.coachGender ?? '').trim();
    if (gender.isNotEmpty &&
        gender.toLowerCase() != 'no preference' &&
        gender.toLowerCase() != 'any') {
      items.add('Gender: $gender');
    }
    final ageRange = (preferences.coachAgeRange ?? '').trim();
    if (ageRange.isNotEmpty &&
        ageRange.toLowerCase() != 'no preference' &&
        ageRange.toLowerCase() != 'any') {
      items.add('Age: $ageRange');
    }
    items.add(
      preferences.certifiedOnly
          ? 'Certified coaches only'
          : 'Any verified coach type',
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF5FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E0F2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF5BDCF2)),
              SizedBox(width: 10),
              Text(
                'Your saved preferences',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFD7E0F2)),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  const _RecommendationCard({
    required this.coach,
    required this.rank,
    required this.onBook,
  });

  final _RecommendedCoach coach;
  final int rank;
  final VoidCallback onBook;

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.rank == 1 && widget.coach.score >= 85;
  }

  @override
  void didUpdateWidget(covariant _RecommendationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coach.coachId != widget.coach.coachId ||
        oldWidget.rank != widget.rank) {
      _expanded = widget.rank == 1 && widget.coach.score >= 85;
    }
  }

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;
    final scoreColor = _scoreColor(coach.score);
    final isBest = widget.rank == 1 && coach.score >= 85;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBest ? scoreColor : const Color(0xFFD7E0F2),
          width: isBest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoachAvatar(imageUrl: coach.imageUrl, name: coach.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RankPill(rank: widget.rank, label: coach.rankLabel),
                    const SizedBox(height: 8),
                    Text(
                      coach.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${coach.sport}  -  ${coach.rating.toStringAsFixed(1)}  -  ${coach.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6C7897),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFF36CC7E),
                          size: 9,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            coach.nextFreeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.deepBlue,
                              fontSize: 11,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${coach.price} LE/hr',
                style: const TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coach.matchChips
                .map((chip) => _MatchChip(label: chip.label, matched: chip.ok))
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepBlue,
                    side: const BorderSide(color: AppColors.deepBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _expanded
                        ? 'Hide recommendation'
                        : 'Why recommend this coach?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 96,
                height: 42,
                child: ElevatedButton(
                  onPressed: widget.onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            _WhyCoachPanel(coach: coach),
          ],
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 82,
        height: 98,
        color: const Color(0xFFEAF0FB),
        child: imageUrl.isEmpty
            ? Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
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
                      color: AppColors.deepBlue,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  const _RankPill({required this.rank, required this.label});

  final int rank;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isBest = rank == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBest ? const Color(0xFF20A85A) : const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$rank  $label',
        style: TextStyle(
          color: isBest ? Colors.white : AppColors.deepBlue,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip({required this.label, required this.matched});

  final String label;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: matched ? const Color(0xFFF4FFF8) : const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: matched ? const Color(0xFF42B875) : const Color(0xFFD7E0F2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched ? Icons.check_rounded : Icons.close_rounded,
            size: 14,
            color: matched ? const Color(0xFF218B54) : const Color(0xFF7C8498),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: matched
                  ? const Color(0xFF218B54)
                  : const Color(0xFF7C8498),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyCoachPanel extends StatelessWidget {
  const _WhyCoachPanel({required this.coach});

  final _RecommendedCoach coach;

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(coach.score);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9EFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why this coach?',
            style: TextStyle(
              color: Color(0xFF218B54),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...coach.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(reason.icon, color: const Color(0xFF6C7897), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason.title,
                      style: const TextStyle(
                        color: Color(0xFF6C7897),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: reason.matched
                              ? Colors.white
                              : const Color(0xFFFFF7E8),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: reason.matched
                                ? const Color(0xFF42B875)
                                : const Color(0xFFE89113),
                          ),
                        ),
                        child: Text(
                          reason.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: reason.matched
                                ? const Color(0xFF218B54)
                                : const Color(0xFFE89113),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scoreColor.withValues(alpha: 0.34)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: scoreColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommendation score',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${coach.score.round()}%',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

class _HowAiWorksSheet extends StatelessWidget {
  const _HowAiWorksSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFB9C3D8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'How does AI recommendation work?',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontSize: 27,
                height: 1.05,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Maranny ranks coaches to save your time and help you choose faster.',
              style: TextStyle(
                color: Color(0xFF6C7897),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _HowItem(
            icon: Icons.tune_rounded,
            title: 'Reads your preferences',
            subtitle:
                'Sport, area, budget, coach gender, age range, certification, and rating goals.',
          ),
          const _HowItem(
            icon: Icons.gps_fixed_rounded,
            title: 'Matches coaches automatically',
            subtitle:
                'Coaches are compared with your saved preferences and real booking data.',
          ),
          const _HowItem(
            icon: Icons.leaderboard_rounded,
            title: 'Ranks the best options first',
            subtitle:
                'The strongest matches appear at the top with a clear recommendation score.',
          ),
          const _HowItem(
            icon: Icons.info_outline_rounded,
            title: 'Explains every recommendation',
            subtitle: 'Green matches show exactly why a coach fits your needs.',
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 18),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBDEFFF)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE2F7FF),
                  child: Icon(
                    Icons.timer_outlined,
                    color: AppColors.deepBlue,
                    size: 30,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saves time and effort',
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Instead of checking every coach manually, Maranny shows the most suitable coaches first.',
                        style: TextStyle(
                          color: Color(0xFF6C7897),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItem extends StatelessWidget {
  const _HowItem({
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.deepBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6C7897),
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 36),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.deepBlue, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6C7897)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onTap, child: Text(buttonText)),
        ],
      ),
    );
  }
}

class _RecommendedCoach {
  final Map<String, dynamic> raw;
  final int coachId;
  final int? sportId;
  final String name;
  final String sport;
  final List<String> sports;
  final String location;
  final List<String> locations;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int price;
  final String bio;
  final int totalStudents;
  final int totalSessions;
  final double hoursTaught;
  final List<String> availableDays;
  final String nextFreeText;
  final double score;
  final bool isEligible;
  final List<_MatchResult> matchChips;
  final List<_Reason> reasons;

  const _RecommendedCoach({
    required this.raw,
    required this.coachId,
    required this.sportId,
    required this.name,
    required this.sport,
    required this.sports,
    required this.location,
    required this.locations,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.bio,
    required this.totalStudents,
    required this.totalSessions,
    required this.hoursTaught,
    required this.availableDays,
    required this.nextFreeText,
    required this.score,
    required this.isEligible,
    required this.matchChips,
    required this.reasons,
  });

  String get rankLabel {
    if (score >= 90) return 'Best match';
    if (score >= 78) return 'Strong match';
    if (score >= 62) return 'Good option';
    return 'Alternative';
  }

  factory _RecommendedCoach.fromJson(
    Map<String, dynamic> coach,
    UserPreferences prefs,
  ) {
    final sports = _coachSportNames(coach);
    final sport = sports.isNotEmpty
        ? sports.first
        : _firstText([coach['sport'], coach['sportName']], fallback: 'Coach');
    final locations = _coachLocations(coach);
    final location = locations.isNotEmpty
        ? locations.first
        : _firstText([
            coach['area'],
            coach['city'],
            coach['location'],
          ], fallback: 'Nearby');
    final price = _coachPrice(coach);
    final rating = _coachRating(coach);
    final availableDays = _stringList(coach['availableDays']);

    final sportMatch =
        prefs.sports.isEmpty ||
        prefs.sports.any((pref) {
          return sports.any((coachSport) => _textMatches(coachSport, pref));
        });
    final locationMatch = _locationMatches(locations, prefs);
    final priceMatch = _budgetMatches(price, prefs);
    final ratingMatch = prefs.minRating == null || rating >= prefs.minRating!;
    final genderMatch = _genderMatches(coach, prefs);
    final ageMatch = _ageMatches(coach, prefs);
    final certifiedMatch = _certifiedMatches(coach, prefs);

    var matchedWeight = 0.0;
    var totalWeight = 0.0;
    void addCriterion(bool active, bool matched, double weight) {
      if (!active) return;
      totalWeight += weight;
      if (matched) matchedWeight += weight;
    }

    addCriterion(prefs.sports.isNotEmpty, sportMatch, 30);
    addCriterion(_hasLocationPreference(prefs), locationMatch, 20);
    addCriterion(_hasBudgetPreference(prefs), priceMatch, 20);
    addCriterion(prefs.minRating != null, ratingMatch, 14);
    addCriterion(_hasGenderPreference(prefs), genderMatch, 8);
    addCriterion(_hasAgePreference(prefs), ageMatch, 8);
    addCriterion(prefs.certifiedOnly, certifiedMatch, 10);

    final qualityScore = rating > 0 ? (rating.clamp(0, 5) / 5) * 10 : 4.0;
    matchedWeight += qualityScore;
    totalWeight += 10;

    final score =
        (totalWeight == 0
                ? 0.0
                : ((matchedWeight / totalWeight) * 100).clamp(0, 100))
            .toDouble();

    final isEligible =
        (prefs.sports.isEmpty || sportMatch) &&
        (!_hasBudgetPreference(prefs) || priceMatch) &&
        (prefs.minRating == null || ratingMatch) &&
        (!_hasGenderPreference(prefs) || genderMatch) &&
        (!_hasAgePreference(prefs) || ageMatch) &&
        (!prefs.certifiedOnly || certifiedMatch) &&
        (!_hasLocationPreference(prefs) || locationMatch) &&
        score >= 55;

    final matchChips = [
      if (prefs.sports.isNotEmpty) _MatchResult('Sport', sportMatch),
      if (_hasLocationPreference(prefs))
        _MatchResult('Location', locationMatch),
      if (_hasBudgetPreference(prefs)) _MatchResult('Price', priceMatch),
      if (prefs.minRating != null) _MatchResult('Rating', ratingMatch),
      if (_hasGenderPreference(prefs)) _MatchResult('Gender', genderMatch),
      if (_hasAgePreference(prefs)) _MatchResult('Age', ageMatch),
      if (prefs.certifiedOnly) _MatchResult('Certified', certifiedMatch),
    ];

    final reasons = [
      if (prefs.sports.isNotEmpty)
        _Reason(
          Icons.sports_soccer_rounded,
          'Sport preference',
          sportMatch ? '${_matchedSport(sports, prefs)} matched' : 'No match',
          sportMatch,
        ),
      if (_hasLocationPreference(prefs))
        _Reason(
          Icons.location_on_outlined,
          'Location preference',
          locationMatch ? '$location matched' : 'Outside selected area',
          locationMatch,
        ),
      if (_hasBudgetPreference(prefs))
        _Reason(
          Icons.payments_outlined,
          'Budget preference',
          priceMatch
              ? '${price == 0 ? 'Price not set' : '$price LE/hr'} fits'
              : '$price LE/hr outside budget',
          priceMatch,
        ),
      if (prefs.minRating != null)
        _Reason(
          Icons.star_border_rounded,
          'Rating preference',
          ratingMatch
              ? '${rating.toStringAsFixed(1)} meets rating'
              : '${rating.toStringAsFixed(1)} below target',
          ratingMatch,
        ),
      if (_hasGenderPreference(prefs))
        _Reason(
          Icons.person_outline_rounded,
          'Gender preference',
          genderMatch ? '${_coachGender(coach)} matched' : 'Different gender',
          genderMatch,
        ),
      if (_hasAgePreference(prefs))
        _Reason(
          Icons.cake_outlined,
          'Age preference',
          ageMatch ? '${_coachAge(coach) ?? 'Age'} matched' : 'Outside range',
          ageMatch,
        ),
      if (prefs.certifiedOnly)
        _Reason(
          Icons.verified_outlined,
          'Certification preference',
          certifiedMatch ? 'Certified coach' : 'Not certified',
          certifiedMatch,
        ),
      _Reason(
        Icons.query_stats_rounded,
        'Coach quality',
        rating > 0
            ? '${rating.toStringAsFixed(1)} rating from real reviews'
            : 'New coach profile',
        rating >= 4 || rating == 0,
      ),
    ];

    return _RecommendedCoach(
      raw: coach,
      coachId: _coachId(coach),
      sportId: _coachSportIds(coach).isNotEmpty
          ? _coachSportIds(coach).first
          : null,
      name: _firstText([
        coach['name'],
        coach['coachName'],
        coach['fullName'],
      ], fallback: 'Coach'),
      sport: sport,
      sports: sports,
      location: location,
      locations: locations,
      imageUrl: _coachImage(coach),
      rating: rating,
      reviewCount: _coachReviews(coach),
      price: price,
      bio: _firstText([
        coach['bio'],
        coach['description'],
      ], fallback: 'Professional coach with experience.'),
      totalStudents: _coachTotalStudents(coach),
      totalSessions: _coachTotalSessions(coach),
      hoursTaught: _coachHoursTaught(coach),
      availableDays: availableDays,
      nextFreeText: _nextFreeText(coach),
      score: score,
      isEligible: isEligible,
      matchChips: matchChips,
      reasons: reasons,
    );
  }
}

class _MatchResult {
  final String label;
  final bool ok;

  const _MatchResult(this.label, this.ok);
}

class _Reason {
  final IconData icon;
  final String title;
  final String value;
  final bool matched;

  const _Reason(this.icon, this.title, this.value, this.matched);
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

List<int> _coachSportIds(Map<String, dynamic> coach) {
  final ids = <int>[];
  final sports = coach['sports'];
  if (sports is List) {
    for (final sport in sports) {
      if (sport is Map) {
        final value = sport['id'] ?? sport['sportID'] ?? sport['sportId'];
        final parsed = value is num
            ? value.toInt()
            : int.tryParse(value?.toString() ?? '');
        if (parsed != null) ids.add(parsed);
      }
    }
  }
  final direct = coach['sportID'] ?? coach['sportId'];
  final parsed = direct is num
      ? direct.toInt()
      : int.tryParse(direct?.toString() ?? '');
  if (parsed != null) ids.add(parsed);
  return ids.toSet().toList(growable: false);
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

bool _hasLocationPreference(UserPreferences prefs) {
  return (prefs.area ?? '').trim().isNotEmpty ||
      (prefs.city ?? '').trim().isNotEmpty;
}

bool _hasBudgetPreference(UserPreferences prefs) {
  return prefs.budgetMin != null || prefs.budgetMax != null;
}

bool _budgetMatches(int price, UserPreferences prefs) {
  if (!_hasBudgetPreference(prefs)) return true;
  if (price <= 0) return false;
  final min = prefs.budgetMin;
  final max = prefs.budgetMax;
  if (min != null && price < min) return false;
  if (max != null && price > max) return false;
  return true;
}

bool _hasGenderPreference(UserPreferences prefs) {
  final preferred = (prefs.coachGender ?? '').trim().toLowerCase();
  return preferred.isNotEmpty &&
      preferred != 'any' &&
      preferred != 'no preference' &&
      preferred != 'all';
}

bool _genderMatches(Map<String, dynamic> coach, UserPreferences prefs) {
  final preferred = (prefs.coachGender ?? '').trim().toLowerCase();
  if (!_hasGenderPreference(prefs)) {
    return true;
  }

  final gender = _coachGender(coach).toLowerCase();
  return gender.isNotEmpty && gender == preferred;
}

String _coachGender(Map<String, dynamic> coach) {
  final user = coach['user'];
  return _firstText([
    coach['gender'],
    coach['coachGender'],
    if (user is Map) user['gender'],
  ], fallback: 'Not specified');
}

bool _hasAgePreference(UserPreferences prefs) {
  final preferred = (prefs.coachAgeRange ?? '').trim().toLowerCase();
  return preferred.isNotEmpty &&
      preferred != 'any' &&
      preferred != 'no preference' &&
      preferred != 'all';
}

bool _ageMatches(Map<String, dynamic> coach, UserPreferences prefs) {
  if (!_hasAgePreference(prefs)) return true;
  final age = _coachAge(coach);
  if (age == null) return false;
  final range = prefs.coachAgeRange!.toLowerCase();
  final numbers = RegExp(r'\d+')
      .allMatches(range)
      .map((match) => int.tryParse(match.group(0) ?? ''))
      .whereType<int>()
      .toList(growable: false);
  if (numbers.length >= 2) {
    return age >= numbers[0] && age <= numbers[1];
  }
  if (numbers.length == 1) {
    if (range.contains('+')) return age >= numbers[0];
    return age == numbers[0];
  }
  return true;
}

int? _coachAge(Map<String, dynamic> coach) {
  final user = coach['user'];
  final value = _firstPositiveInt([
    coach['age'],
    coach['coachAge'],
    if (user is Map) user['age'],
  ]);
  return value > 0 ? value : null;
}

bool _certifiedMatches(Map<String, dynamic> coach, UserPreferences prefs) {
  if (!prefs.certifiedOnly) return true;
  final status = _firstText([
    coach['verificationStatus'],
    coach['status'],
  ]).toLowerCase();
  final certificateUrl = _firstText([
    coach['certificateUrl'],
    coach['certificateImageUrl'],
  ]);
  return coach['isCertified'] == true ||
      coach['certified'] == true ||
      certificateUrl.isNotEmpty ||
      status == 'verified' ||
      status == 'approved' ||
      status == 'accepted';
}

String _matchedSport(List<String> coachSports, UserPreferences prefs) {
  for (final pref in prefs.sports) {
    for (final sport in coachSports) {
      if (_textMatches(sport, pref)) {
        return sport;
      }
    }
  }
  return coachSports.isNotEmpty ? coachSports.first : 'Sport';
}

bool _textMatches(String left, String right) {
  final a = left.toLowerCase().trim();
  final b = right.toLowerCase().trim();
  if (a.isEmpty || b.isEmpty) return false;
  return a == b || a.contains(b) || b.contains(a);
}

Color _scoreColor(double score) {
  if (score >= 85) return const Color(0xFF20A85A);
  if (score >= 70) return const Color(0xFF2A8CEB);
  if (score >= 55) return const Color(0xFFE89113);
  return const Color(0xFFE64B4B);
}

int _coachId(Map<String, dynamic> coach) {
  final value = coach['coachID'] ?? coach['coachId'] ?? coach['id'];
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _coachRating(Map<String, dynamic> coach) {
  final value = coach['avgRating'] ?? coach['rating'] ?? coach['averageRating'];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _coachReviews(Map<String, dynamic> coach) {
  final value =
      coach['totalReviews'] ?? coach['reviewCount'] ?? coach['reviews'];
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _coachPrice(Map<String, dynamic> coach) {
  final direct = _firstPositiveInt([
    coach['sessionPrice'],
    coach['pricePerSession'],
    coach['startingPrice'],
    coach['hourlyRate'],
    coach['price'],
  ]);
  if (direct > 0) return direct;

  final sports = coach['sports'];
  if (sports is List) {
    for (final sport in sports) {
      if (sport is Map) {
        final price = _firstPositiveInt([sport['pricePerSession']]);
        if (price > 0) return price;
      }
    }
  }
  return 0;
}

int _coachTotalStudents(Map<String, dynamic> coach) {
  return _firstPositiveInt([
    coach['totalStudents'],
    coach['studentsCount'],
    coach['studentCount'],
    coach['totalClients'],
    coach['clientsCount'],
    coach['bookedClients'],
  ]);
}

int _coachTotalSessions(Map<String, dynamic> coach) {
  return _firstPositiveInt([
    coach['totalSessions'],
    coach['sessionsCount'],
    coach['sessionCount'],
    coach['completedSessions'],
    coach['completedSessionCount'],
    coach['bookingsCount'],
  ]);
}

double _coachHoursTaught(Map<String, dynamic> coach) {
  for (final value in [
    coach['hoursTaught'],
    coach['hoursTrained'],
    coach['totalHours'],
    coach['totalHoursTaught'],
    coach['trainingHours'],
  ]) {
    if (value is num && value >= 0) return value.toDouble();
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null && parsed >= 0) return parsed.toDouble();
  }
  return 0;
}

int _firstPositiveInt(List<dynamic> values) {
  for (final value in values) {
    if (value is num && value > 0) return value.round();
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null && parsed > 0) return parsed.round();
  }
  return 0;
}

String _coachImage(Map<String, dynamic> coach) {
  final user = coach['user'];
  final raw = _firstText([
    coach['profilePictureUrl'],
    coach['profilePicture'],
    coach['imageUrl'],
    coach['image'],
    coach['photoUrl'],
    coach['url'],
    if (user is Map) user['profilePictureUrl'],
    if (user is Map) user['profilePicture'],
    if (user is Map) user['imageUrl'],
  ]);
  return ApiConfig.resolveMediaUrl(raw);
}

String _nextFreeText(Map<String, dynamic> coach) {
  final upcomingDates = coach['upcomingAvailableDates'];
  if (upcomingDates is List && upcomingDates.isNotEmpty) {
    final first = upcomingDates.first;
    if (first is Map) {
      final date = (first['date'] ?? first['sessionDate'] ?? '').toString();
      final day = (first['dayName'] ?? first['day'] ?? '').toString();
      final hours = first['availableHours'] ?? first['hours'];
      final firstHour = hours is List && hours.isNotEmpty
          ? hours.first.toString()
          : '';
      if (firstHour.isNotEmpty) {
        return 'NEXT FREE  -  ${_shortDay(day, date)}  -  $firstHour';
      }
    }
  }

  final availableDays = coach['availableDays'];
  final availableHours = coach['availableHours'];
  final firstDay = availableDays is List && availableDays.isNotEmpty
      ? availableDays.first.toString()
      : '';
  final firstHour = availableHours is List && availableHours.isNotEmpty
      ? availableHours.first.toString()
      : '';
  if (firstDay.isNotEmpty && firstHour.isNotEmpty) {
    return 'NEXT FREE  -  ${_shortDay(firstDay, '')}  -  $firstHour';
  }
  return 'CHECK FREE SLOTS';
}

String _shortDay(String rawDay, String rawDate) {
  final day = rawDay.trim();
  if (day.isNotEmpty) return day.length <= 3 ? day : day.substring(0, 3);
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) return 'Soon';
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[parsed.weekday - 1];
}
