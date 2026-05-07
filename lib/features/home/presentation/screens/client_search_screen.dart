import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../../../bookings/presentation/screens/coach_details_screen.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/domain/models/coach_data_model.dart';
import '../../../profile/data/repositories/profile_repository.dart';

const Map<String, List<String>> _egyptLocations = {
  'Cairo': [
    'Nasr City',
    'Maadi',
    'Heliopolis',
    'New Cairo',
    'Zamalek',
    'Dokki',
    'Mohandessin',
    '6th of October',
  ],
  'Alexandria': [
    'Smouha',
    'Miami',
    'Montazah',
    'Sporting',
    'Sidi Bishr',
    'Stanley',
    'Gleem',
  ],
  'Giza': ['Sheikh Zayed', 'Haram', 'Faisal', 'Agouza', 'Imbaba'],
  'New Cairo': ['5th Settlement', 'Rehab', 'Madinaty', 'Shorouk', 'Badr City'],
  'North Coast': ['Marina', 'Sahel', 'Sidi Abdel Rahman', 'Hacienda'],
  'Red Sea': ['Hurghada', 'El Gouna', 'Sharm El Sheikh', 'Ain Sokhna'],
};

class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  State<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  final _searchController = TextEditingController();
  final ProfileRepository _profileRepository = ProfileRepository();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const double _defaultMaxPrice = 10000;

  double _maxPrice = _defaultMaxPrice;
  String? _selectedCity;
  String? _selectedArea;
  String _certification = "Doesn't Matter";
  String _ratingFilter = "Doesn't Matter";
  bool _filterApplied = false;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _coaches = [];

  final List<String> _categories = [
    'All',
    'Football',
    'Horse Riding',
    'Yoga',
    'Fitness',
    'Swimming',
    'Tennis',
    'Basketball',
  ];

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  int? _sportIdFromCategory(String category) {
    switch (category) {
      case 'Football':
        return 1;
      case 'Yoga':
        return 2;
      case 'Swimming':
        return 3;
      case 'Fitness':
        return 4;
      case 'Tennis':
        return 5;
      case 'Basketball':
        return 6;
      case 'Horse Riding':
        return 7;
      default:
        return null;
    }
  }

  String _normalizedSportName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  List<int> _coachSportIds(Map<String, dynamic> coach) {
    final ids = <int>[];
    final sports = coach['sports'];
    if (sports is List) {
      for (final sport in sports) {
        if (sport is Map<String, dynamic>) {
          final rawId = sport['id'] ?? sport['sportID'] ?? sport['sportId'];
          if (rawId is int) {
            ids.add(rawId);
          } else if (rawId is num) {
            ids.add(rawId.toInt());
          } else if (rawId is String) {
            final parsed = int.tryParse(rawId);
            if (parsed != null) {
              ids.add(parsed);
            }
          }
        }
      }
    }

    final directId = coach['sportID'] ?? coach['sportId'];
    if (directId is int) {
      ids.add(directId);
    } else if (directId is num) {
      ids.add(directId.toInt());
    } else if (directId is String) {
      final parsed = int.tryParse(directId);
      if (parsed != null) {
        ids.add(parsed);
      }
    }

    return ids.toSet().toList(growable: false);
  }

  List<String> _coachSportNames(Map<String, dynamic> coach) {
    final names = <String>[];
    final sports = coach['sports'];
    if (sports is List) {
      for (final sport in sports) {
        if (sport is Map<String, dynamic>) {
          final name = (sport['name'] ?? sport['sportName'] ?? '').toString();
          if (name.trim().isNotEmpty) {
            names.add(name.trim());
          }
        } else {
          final text = sport.toString().trim();
          if (text.isNotEmpty) {
            names.add(text);
          }
        }
      }
    }

    final directName = (coach['sport'] ?? coach['sportName'] ?? '')
        .toString()
        .trim();
    if (directName.isNotEmpty) {
      names.add(directName);
    }

    return names.toSet().toList(growable: false);
  }

  bool _matchesSelectedSport(Map<String, dynamic> coach) {
    if (_selectedCategory == 'All') {
      return true;
    }

    final selectedSportId = _sportIdFromCategory(_selectedCategory);
    final coachSportIds = _coachSportIds(coach);
    if (selectedSportId != null && coachSportIds.isNotEmpty) {
      return coachSportIds.contains(selectedSportId);
    }

    final selectedSportName = _normalizedSportName(_selectedCategory);
    final coachSportNames = _coachSportNames(coach);
    return coachSportNames.any(
      (name) => _normalizedSportName(name) == selectedSportName,
    );
  }

  double? _minRatingFromFilter(String value) {
    if (value == '4.5+') return 4.5;
    if (value == '4.0+') return 4.0;
    if (value == '3.0+') return 3.0;
    return null;
  }

  bool? _verifiedOnlyFromCertification(String value) {
    if (value == 'Only Certified Coaches') return true;
    return null;
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final selectedSportId = _sportIdFromCategory(_selectedCategory);
      developer.log(
        'ClientSearchScreen load coaches -> '
        'selectedChip=$_selectedCategory '
        'mappedSportID=$selectedSportId '
        'searchQuery=$_searchQuery '
        'city=${_selectedCity ?? ''}',
        name: 'ClientSearchScreen',
      );
      print(
        '[ClientSearchScreen] load coaches -> '
        'selectedChip=$_selectedCategory '
        'mappedSportID=$selectedSportId '
        'searchQuery=$_searchQuery '
        'city=${_selectedCity ?? ''}',
      );

      final data = await _profileRepository.searchCoachesList(
        name: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        sportID: selectedSportId,
        city: _selectedCity,
        minRating: _minRatingFromFilter(_ratingFilter),
        verifiedOnly: _filterApplied
            ? _verifiedOnlyFromCertification(_certification)
            : null,
        page: 1,
        pageSize: 20,
      );
      final filteredData = data.where(_matchesSelectedSport).toList(growable: false);

      developer.log(
        'ClientSearchScreen coaches response -> '
        'selectedChip=$_selectedCategory '
        'mappedSportID=$selectedSportId '
        'rawCount=${data.length} '
        'filteredCount=${filteredData.length}',
        name: 'ClientSearchScreen',
      );
      print(
        '[ClientSearchScreen] coaches response -> '
        'selectedChip=$_selectedCategory '
        'mappedSportID=$selectedSportId '
        'rawCount=${data.length} '
        'filteredCount=${filteredData.length}',
      );
      for (final coach in data) {
        final coachName = _coachName(coach);
        final sportNames = _coachSportNames(coach);
        final sportIds = _coachSportIds(coach);
        developer.log(
          'ClientSearchScreen coach -> '
          'name=$coachName '
          'sportNames=${jsonEncode(sportNames)} '
          'sportIDs=${jsonEncode(sportIds)}',
          name: 'ClientSearchScreen',
        );
        print(
          '[ClientSearchScreen] coach -> '
          'name=$coachName '
          'sportNames=${jsonEncode(sportNames)} '
          'sportIDs=${jsonEncode(sportIds)}',
        );
      }

      if (!mounted) return;
      setState(() {
        _coaches = filteredData;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load coaches';
        _isLoading = false;
      });
    }
  }

  String _coachName(Map<String, dynamic> coach) {
    return (coach['name'] ??
            coach['coachName'] ??
            coach['fullName'] ??
            'Unknown Coach')
        .toString();
  }

  String _coachSport(Map<String, dynamic> coach) {
    final sports = coach['sports'];
    if (sports is List && sports.isNotEmpty) {
      final first = sports.first;
      if (first is Map<String, dynamic>) {
        return (first['name'] ?? first['sportName'] ?? 'Coach').toString();
      }
      return first.toString();
    }

    return (coach['sport'] ?? coach['sportName'] ?? 'Coach').toString();
  }

  String _coachDescription(Map<String, dynamic> coach) {
    return (coach['bio'] ??
            coach['description'] ??
            'Professional coach with experience')
        .toString();
  }

  double _coachRating(Map<String, dynamic> coach) {
    final value = coach['avgRating'] ?? coach['rating'];
    if (value is num) return value.toDouble();
    return 0;
  }

  int _coachReviews(Map<String, dynamic> coach) {
    final value =
        coach['totalReviews'] ?? coach['reviewCount'] ?? coach['reviews'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  int _coachPrice(Map<String, dynamic> coach) {
    final sports = coach['sports'];
    if (sports is List && sports.isNotEmpty) {
      final first = sports.first;
      if (first is Map<String, dynamic>) {
        final price = first['pricePerSession'];
        if (price is num) return price.toInt();
      }
    }

    final value =
        coach['startingPrice'] ?? coach['price'] ?? coach['pricePerSession'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String _coachCity(Map<String, dynamic> coach) {
    final locations = coach['locations'];
    if (locations is List && locations.isNotEmpty) {
      return locations.first.toString();
    }

    return (coach['city'] ?? coach['location'] ?? '').toString();
  }

  String _coachArea(Map<String, dynamic> coach) {
    return (coach['area'] ?? '').toString();
  }

  int _coachId(Map<String, dynamic> coach) {
    final value = coach['coachID'] ?? coach['coachId'] ?? coach['id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String _coachImage(Map<String, dynamic> coach) {
    return (coach['profilePictureUrl'] ??
            coach['imageUrl'] ??
            coach['url'] ??
            '')
        .toString();
  }

  Color _coachColor(Map<String, dynamic> coach) {
    final sport = _coachSport(coach).toLowerCase();
    if (sport.contains('football')) return const Color(0xFF1565C0);
    if (sport.contains('swimming')) return const Color(0xFF6A1B9A);
    if (sport.contains('yoga')) return const Color(0xFF880E4F);
    if (sport.contains('padel')) return const Color(0xFF1B5E20);
    if (sport.contains('fitness')) return const Color(0xFFE65100);
    return const Color(0xFF1565C0);
  }

  void _openCoachDetails(Map<String, dynamic> coach) {
    final name = _coachName(coach);
    final sport = _coachSport(coach);
    final city = _coachCity(coach);
    final area = _coachArea(coach);
    final availableDays =
        ((coach['availableDays'] as List<dynamic>?) ?? const [])
            .map((day) => day.toString())
            .where((day) => day.isNotEmpty)
            .toList();
    final coachSportIds = _coachSportIds(coach);
    final selectedCoachSportId = coachSportIds.isNotEmpty ? coachSportIds.first : _sportIdFromCategory(sport);

    final location = area.isNotEmpty ? '$area, $city' : city;

    final session = BookingSessionModel(
      id: name.replaceAll(' ', '_'),
      coachUserId: _coachId(coach),
      sportId: selectedCoachSportId,
      coachName: name,
      sport: sport,
      location: location,
      date: DateTime.now(),
      isPast: false,
      isReviewed: false,
    );

    final coachData = CoachData(
      name: name,
      sport: sport,
      sportId: selectedCoachSportId,
      location: location,
      image: _coachImage(coach),
      availableDays: availableDays,
      rating: _coachRating(coach),
      reviewCount: _coachReviews(coach),
      price: _coachPrice(coach),
      bio: _coachDescription(coach),
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
          image: _coachImage(coach),
          coachData: coachData,
        ),
      ),
    );
  }

  void _openFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        initialMaxPrice: _maxPrice,
        initialCity: _selectedCity,
        initialArea: _selectedArea,
        initialCertification: _certification,
        initialRating: _ratingFilter,
        onApply: (maxPrice, city, area, certification, rating) {
          setState(() {
            _maxPrice = maxPrice;
            _selectedCity = city;
            _selectedArea = area;
            _certification = certification;
            _ratingFilter = rating;
            _filterApplied = true;
          });
          _loadCoaches();
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredByPrice = _coaches.where((coach) {
      final price = _coachPrice(coach);
      return !_filterApplied || price == 0 || price <= _maxPrice;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) {
                            setState(() => _searchQuery = v);
                            Future.delayed(
                              const Duration(milliseconds: 350),
                              () {
                                if (mounted && _searchQuery == v) {
                                  _loadCoaches();
                                }
                              },
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'Browse coaches by name',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final selected = _selectedCategory == cat;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _loadCoaches();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1F3A93)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1F3A93)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _openFilter,
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: _filterApplied
                            ? const Color(0xFF1F3A93)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Advanced filter',
                        style: TextStyle(
                          fontSize: 13,
                          color: _filterApplied
                              ? const Color(0xFF1F3A93)
                              : Colors.grey.shade600,
                          fontWeight: _filterApplied
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (_filterApplied) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F3A93),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ON',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: TextButton(
                      onPressed: _loadCoaches,
                      child: Text(_error!),
                    ),
                  )
                : filteredByPrice.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No coaches match your filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredByPrice.length,
                    itemBuilder: (context, index) => _CoachCard(
                      coach: filteredByPrice[index],
                      name: _coachName(filteredByPrice[index]),
                      sport: _coachSport(filteredByPrice[index]),
                      description: _coachDescription(filteredByPrice[index]),
                      rating: _coachRating(filteredByPrice[index]),
                      reviews: _coachReviews(filteredByPrice[index]),
                      city: _coachCity(filteredByPrice[index]),
                      area: _coachArea(filteredByPrice[index]),
                      price: _coachPrice(filteredByPrice[index]),
                      color: _coachColor(filteredByPrice[index]),
                      image: _coachImage(filteredByPrice[index]),
                      onTap: () => _openCoachDetails(filteredByPrice[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final double initialMaxPrice;
  final String? initialCity;
  final String? initialArea;
  final String initialCertification;
  final String initialRating;
  final Function(double, String?, String?, String, String) onApply;

  const _FilterSheet({
    required this.initialMaxPrice,
    required this.initialCity,
    required this.initialArea,
    required this.initialCertification,
    required this.initialRating,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _maxPrice;
  String? _selectedCity;
  String? _selectedArea;
  late String _certification;
  late String _rating;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.initialMaxPrice;
    _selectedCity = widget.initialCity;
    _selectedArea = widget.initialArea;
    _certification = widget.initialCertification;
    _rating = widget.initialRating;
  }

  int get _activeCount {
    int c = 0;
    if (_maxPrice < _ClientSearchScreenState._defaultMaxPrice) c++;
    if (_selectedCity != null) c++;
    if (_selectedArea != null) c++;
    if (_certification != "Doesn't Matter") c++;
    if (_rating != "Doesn't Matter") c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final areas = _selectedCity != null
        ? _egyptLocations[_selectedCity!] ?? []
        : <String>[];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Filter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Range price per session',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxPrice,
              min: 100,
              max: _ClientSearchScreenState._defaultMaxPrice,
              divisions: 99,
              activeColor: const Color(0xFF1F3A93),
              onChanged: (v) => setState(() => _maxPrice = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '100 LE',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '${_maxPrice.toInt()} LE',
                  style: const TextStyle(
                    color: Color(0xFF1F3A93),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_ClientSearchScreenState._defaultMaxPrice.toInt()} LE',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _egyptLocations.keys.map((city) {
                final selected = _selectedCity == city;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCity = selected ? null : city;
                    _selectedArea = null;
                  }),
                  child: _chip(city, selected),
                );
              }).toList(),
            ),
            if (_selectedCity != null && areas.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Area in $_selectedCity',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: areas.map((area) {
                  final selected = _selectedArea == area;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedArea = selected ? null : area;
                    }),
                    child: _chip(area, selected),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Coach Certification',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'Only Certified Coaches',
                        'Certified Preferred',
                        "Doesn't Matter",
                      ]
                      .map(
                        (opt) => GestureDetector(
                          onTap: () => setState(() => _certification = opt),
                          child: _chip(opt, _certification == opt),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Coach Rating',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['4.5+', '4.0+', '3.0+', "Doesn't Matter"].map((opt) {
                final hasStars = opt != "Doesn't Matter";
                final selected = _rating == opt;

                return GestureDetector(
                  onTap: () => setState(() => _rating = opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1F3A93) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1F3A93)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasStars) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: selected ? Colors.white : Colors.amber,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _maxPrice,
                    _selectedCity,
                    _selectedArea,
                    _certification,
                    _rating,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A93),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _activeCount > 0 ? 'Apply ($_activeCount)' : 'Apply',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1F3A93) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF1F3A93) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  final String name;
  final String sport;
  final String description;
  final double rating;
  final int reviews;
  final String city;
  final String area;
  final int price;
  final Color color;
  final String image;
  final VoidCallback onTap;

  const _CoachCard({
    required this.coach,
    required this.name,
    required this.sport,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.city,
    required this.area,
    required this.price,
    required this.color,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final location = area.isNotEmpty ? '$area, $city' : city;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person, color: color, size: 32),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: color, size: 32),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        price > 0 ? '$price LE/hr' : 'N/A',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sport,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews reviews)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
}
