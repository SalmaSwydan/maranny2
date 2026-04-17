import 'package:flutter/material.dart';
import '../../../bookings/presentation/screens/coach_details_screen.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/domain/models/coach_data_model.dart';

const Map<String, List<String>> _egyptLocations = {
  'Cairo': ['Nasr City', 'Maadi', 'Heliopolis', 'New Cairo', 'Zamalek', 'Dokki', 'Mohandessin', '6th of October'],
  'Alexandria': ['Smouha', 'Miami', 'Montazah', 'Sporting', 'Sidi Bishr', 'Stanley', 'Gleem'],
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
  String _selectedCategory = 'All';
  String _searchQuery = '';

  double _maxPrice = 1000;
  String? _selectedCity;
  String? _selectedArea;
  String _certification = 'Only Certified Coaches';
  String _ratingFilter = "Doesn't Matter";
  bool _filterApplied = false;

  final List<String> _categories = [
    'All', 'Football', 'Horse Riding', 'Yoga', 'Fitness',
    'Swimming', 'Tennis', 'Basketball',
  ];

  final List<Map<String, dynamic>> _allCoaches = [
    {
      'name': 'Ahmed Mohamed', 'sport': 'Football',
      'description': 'Professional football coach with 10+ experience',
      'rating': 4.9, 'reviews': 80,
      'city': 'Cairo', 'area': 'Nasr City', 'price': 500,
      'color': const Color(0xFF1565C0),
      'image': 'assets/images/coach_ahmed_mohamed.png',
    },
    {
      'name': 'Sarah Ahmed', 'sport': 'Swimming',
      'description': 'Professional swimming coach with 10+ experience',
      'rating': 4.9, 'reviews': 80,
      'city': 'Cairo', 'area': 'Maadi', 'price': 400,
      'color': const Color(0xFF6A1B9A),
      'image': 'assets/images/coach_sarah_Ahmed.jpeg',
    },
    {
      'name': 'Nancy Ali', 'sport': 'Yoga',
      'description': 'Professional yoga coach with 10+ experience',
      'rating': 4.9, 'reviews': 80,
      'city': 'Giza', 'area': 'Sheikh Zayed', 'price': 350,
      'color': const Color(0xFF880E4F),
      'image': 'assets/images/coach_nancy_ali.png',
    },
    {
      'name': 'Ziad Marwan', 'sport': 'Padel',
      'description': 'Professional padel coach with 10+ experience',
      'rating': 4.9, 'reviews': 80,
      'city': 'New Cairo', 'area': '5th Settlement', 'price': 600,
      'color': const Color(0xFF1B5E20),
      'image': 'assets/images/ZiadMarwanPADEL.jpeg',
    },
    {
      'name': 'Omar Khaled', 'sport': 'Fitness',
      'description': 'Professional fitness coach with 10+ experience',
      'rating': 4.8, 'reviews': 42,
      'city': 'Cairo', 'area': 'Heliopolis', 'price': 300,
      'color': const Color(0xFFE65100),
      'image': 'assets/images/coach_omar_khaled.png',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _allCoaches.where((coach) {
      final matchesCategory = _selectedCategory == 'All' ||
          coach['sport'].toString().toLowerCase() ==
              _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          coach['name'].toString().toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesPrice = (coach['price'] as int) <= _maxPrice;
      double minRating = 0;
      if (_ratingFilter == '4.5+') minRating = 4.5;
      else if (_ratingFilter == '4.0+') minRating = 4.0;
      else if (_ratingFilter == '3.0+') minRating = 3.0;
      final matchesRating = (coach['rating'] as double) >= minRating;
      final matchesCity = _selectedCity == null || coach['city'] == _selectedCity;
      final matchesArea = _selectedArea == null || coach['area'] == _selectedArea;
      return matchesCategory && matchesSearch && matchesPrice &&
          matchesRating && matchesCity && matchesArea;
    }).toList();
  }

  void _openCoachDetails(Map<String, dynamic> coach) {
    final session = BookingSessionModel(
      id: coach['name'].toString().replaceAll(' ', '_'),
      coachName: coach['name'],
      sport: coach['sport'],
      location: '${coach['area']}, ${coach['city']}',
      date: DateTime.now(),
      isPast: false,
      isReviewed: false,
    );
    final coachData = allCoachesData.firstWhere(
          (c) => c.name == coach['name'],
      orElse: () => allCoachesData.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          session: session,
          image: coach['image'] ?? '',
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
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                    ),
                    const Text('Search',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
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
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Browse coaches by name',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none, isDense: true,
                          ),
                        ),
                      ),
                      const Icon(Icons.auto_awesome_outlined,
                          color: Colors.grey, size: 20),
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
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
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
                          child: Text(cat,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87)),
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
                      Icon(Icons.filter_list,
                          size: 18,
                          color: _filterApplied
                              ? const Color(0xFF1F3A93)
                              : Colors.grey),
                      const SizedBox(width: 6),
                      Text('Advanced filter',
                          style: TextStyle(
                              fontSize: 13,
                              color: _filterApplied
                                  ? const Color(0xFF1F3A93)
                                  : Colors.grey.shade600,
                              fontWeight: _filterApplied
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                      if (_filterApplied) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F3A93),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('ON',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No coaches match your filters',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) => _CoachCard(
                coach: _filtered[index],
                onTap: () => _openCoachDetails(_filtered[index]),
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
    if (_maxPrice < 1000) c++;
    if (_selectedCity != null) c++;
    if (_selectedArea != null) c++;
    if (_certification != 'Only Certified Coaches') c++;
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
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Range price per session',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Slider(
              value: _maxPrice,
              min: 100, max: 1000, divisions: 18,
              activeColor: const Color(0xFF1F3A93),
              onChanged: (v) => setState(() => _maxPrice = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('100 LE', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('${_maxPrice.toInt()} LE',
                    style: const TextStyle(color: Color(0xFF1F3A93), fontWeight: FontWeight.bold)),
                Text('1000 LE', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
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
              Text('Area in $_selectedCity',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
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
            const Text('Coach Certification',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['Only Certified Coaches', 'Certified Preferred', "Doesn't Matter"]
                  .map((opt) => GestureDetector(
                onTap: () => setState(() => _certification = opt),
                child: _chip(opt, _certification == opt),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Coach Rating',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['4.5+', '4.0+', '3.0+', "Doesn't Matter"].map((opt) {
                final hasStars = opt != "Doesn't Matter";
                final selected = _rating == opt;
                return GestureDetector(
                  onTap: () => setState(() => _rating = opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1F3A93) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? const Color(0xFF1F3A93) : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasStars) ...[
                          Icon(Icons.star, size: 14,
                              color: selected ? Colors.white : Colors.amber),
                          const SizedBox(width: 4),
                        ],
                        Text(opt,
                            style: TextStyle(
                                fontSize: 13,
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
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
                  widget.onApply(_maxPrice, _selectedCity, _selectedArea,
                      _certification, _rating);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A93),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _activeCount > 0 ? 'Apply ($_activeCount)' : 'Apply',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  final VoidCallback onTap;
  const _CoachCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                coach['image'] ?? '',
                width: 64, height: 64, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: (coach['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person,
                      color: coach['color'] as Color, size: 32),
                ),
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
                      Text(coach['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${coach['price']} LE/hr',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(coach['sport'],
                      style: TextStyle(
                          color: coach['color'] as Color,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(coach['description'],
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('${coach['rating']} (${coach['reviews']} reviews)',
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 6),
                      const Icon(Icons.location_on,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      // ✅ FIX: wrapped in Flexible to prevent 30px overflow
                      Flexible(
                        child: Text(
                          '${coach['area']}, ${coach['city']}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
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