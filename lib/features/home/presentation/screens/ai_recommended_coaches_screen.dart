import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
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
              coach.sport.toLowerCase() == _selectedSport.toLowerCase() ||
              coach.sports.any(
                (sport) => sport.toLowerCase() == _selectedSport.toLowerCase(),
              );

          if (!matchesSport) return false;
          if (normalizedQuery.isEmpty) return true;

          return coach.name.toLowerCase().contains(normalizedQuery) ||
              coach.sport.toLowerCase().contains(normalizedQuery) ||
              coach.location.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String get _preferencesSummary {
    final parts = <String>[];
    if (_preferences.sports.isNotEmpty) {
      parts.add(_preferences.sports.take(2).join(', '));
    }
    if ((_preferences.area ?? '').trim().isNotEmpty) {
      parts.add(_preferences.area!.trim());
    } else if ((_preferences.city ?? '').trim().isNotEmpty) {
      parts.add(_preferences.city!.trim());
    }
    if (_preferences.budgetMax != null) {
      parts.add('<= ${_preferences.budgetMax!.round()} LE/hr');
    }
    if (_preferences.minRating != null) {
      parts.add('${_preferences.minRating!.toStringAsFixed(1)}+ rating');
    } else {
      parts.add('High rating');
    }
    return parts.isEmpty
        ? 'Complete preferences for smarter matches'
        : parts.join('  |  ');
  }

  void _openCoach(_RecommendedCoach coach) {
    final session = BookingSessionModel(
      id: coach.name.replaceAll(' ', '_'),
      coachUserId: coach.coachId,
      sportId: coach.sportId,
      coachName: coach.name,
      sport: coach.sport,
      location: coach.location,
      date: DateTime.now(),
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
      totalStudents: 0,
      totalSessions: 0,
      hoursTaught: 0,
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
                      'Ranked for your goals, budget, location, and availability.',
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
                    _PreferencesCard(summary: _preferencesSummary),
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
                        message: 'Try another sport or search term.',
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
  const _PreferencesCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF5BDCF2)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: 'Your preferences:  '),
                  TextSpan(
                    text: summary,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;
    final isBest = widget.rank == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBest ? const Color(0xFF27B15E) : const Color(0xFFD7E0F2),
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
                width: 78,
                child: ElevatedButton(
                  onPressed: widget.onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Book'),
                ),
              ),
            ],
          ),
          if (_expanded || isBest) ...[
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFF42B875)),
                    ),
                    child: Text(
                      reason.value,
                      style: const TextStyle(
                        color: Color(0xFF218B54),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recommendation score:  ${coach.score.round()}%',
            style: const TextStyle(
              color: Color(0xFF218B54),
              fontSize: 16,
              fontWeight: FontWeight.w900,
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
                'Sport, area, budget, available days, time slots, and rating goals.',
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
  final List<String> availableDays;
  final String nextFreeText;
  final double score;
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
    required this.availableDays,
    required this.nextFreeText,
    required this.score,
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

    final matchChips = [
      _MatchResult('Sport', sportMatch),
      _MatchResult('Location', locationMatch),
      _MatchResult('Price', priceMatch),
      _MatchResult('Time', timeMatch),
      if (prefs.minRating != null) _MatchResult('Rating', ratingMatch),
      if ((prefs.coachGender ?? '').trim().isNotEmpty)
        _MatchResult('Gender', genderMatch),
    ];

    final reasons = [
      _Reason(
        Icons.sports_soccer_rounded,
        'Sport preference',
        sportMatch ? '$sport matched' : 'Different sport',
      ),
      _Reason(
        Icons.location_on_outlined,
        'Location preference',
        locationMatch ? '$location matched' : 'Nearby alternative',
      ),
      _Reason(
        Icons.payments_outlined,
        'Budget preference',
        priceMatch
            ? '${price == 0 ? 'Price' : '$price LE/hr'} fits budget'
            : '$price LE/hr above preference',
      ),
      _Reason(
        Icons.calendar_month_rounded,
        'Availability preference',
        timeMatch
            ? _nextFreeText(coach).replaceAll('NEXT FREE  -  ', '')
            : 'Check slots',
      ),
      _Reason(
        Icons.star_border_rounded,
        'Rating preference',
        ratingMatch ? '${rating.toStringAsFixed(1)} high rating' : 'New coach',
      ),
      const _Reason(
        Icons.groups_outlined,
        'Similar users',
        'Similar users booked this coach',
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
      availableDays: availableDays,
      nextFreeText: _nextFreeText(coach),
      score: score,
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

  const _Reason(this.icon, this.title, this.value);
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
