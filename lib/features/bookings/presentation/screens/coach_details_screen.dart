import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/booking_session_model.dart';
import '../../domain/models/coach_data_model.dart';
import '../widgets/book_session_sheet.dart';

class CoachDetailsScreen extends StatefulWidget {
  final BookingSessionModel session;
  final String image;
  final CoachData? coachData;

  const CoachDetailsScreen({
    super.key,
    required this.session,
    required this.image,
    this.coachData,
  });

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  bool _bioExpanded = false;
  int _selectedTab = 0;
  late final CoachData _data;

  @override
  void initState() {
    super.initState();

    _data =
        widget.coachData ??
        allCoachesData.firstWhere(
          (c) => c.name == widget.session.coachName,
          orElse: () => allCoachesData.firstWhere(
            (c) => c.name.startsWith(widget.session.coachName.split(' ').first),
            orElse: _coachDataFromSession,
          ),
        );
  }

  CoachData _coachDataFromSession() {
    return CoachData(
      name: widget.session.coachName.trim().isEmpty
          ? 'Coach'
          : widget.session.coachName.trim(),
      sport: widget.session.sport.trim().isEmpty
          ? 'Sport'
          : widget.session.sport.trim(),
      sportId: widget.session.sportId,
      location: widget.session.location.trim().isEmpty
          ? 'Location not added yet'
          : widget.session.location.trim(),
      locations: widget.session.location.trim().isEmpty
          ? const []
          : [widget.session.location.trim()],
      image: widget.image,
      rating: 0,
      reviewCount: 0,
      price: 0,
      bio: 'No bio yet',
      totalStudents: 0,
      totalSessions: 0,
      hoursTaught: 0,
      achievements: const [],
      reviews: const [],
    );
  }

  String get _bio => _data.bio;
  int get _totalStudents => _data.totalStudents;
  int get _totalSessions => _data.totalSessions;
  double get _hoursTaught => _data.hoursTaught;
  double get _rating => _data.rating;
  int get _reviewCount => _data.reviewCount;
  int get _price => _data.price;

  String get _image {
    if (widget.image.isNotEmpty) return widget.image;
    return _data.image;
  }

  List<String> get _locations {
    final values = <String>[];
    void add(String value) {
      for (final part in value.split(',')) {
        final cleaned = part.trim();
        if (cleaned.isNotEmpty &&
            cleaned != 'Location not added yet' &&
            !values.contains(cleaned)) {
          values.add(cleaned);
        }
      }
    }

    for (final location in _data.locations) {
      add(location);
    }
    add(_data.location);
    return values;
  }

  List<CoachAchievement> get _achievements => _data.achievements;
  List<CoachReview> get _reviews => _data.reviews;

  bool get _isNetworkImage {
    return _image.startsWith('http://') || _image.startsWith('https://');
  }

  ImageProvider? get _headerImageProvider {
    if (_image.isEmpty) return null;
    return _isNetworkImage ? NetworkImage(_image) : AssetImage(_image);
  }

  void _openBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => BookSessionSheet(
        coachId: widget.session.coachUserId,
        coachSportId: widget.session.sportId ?? widget.coachData?.sportId,
        coachName: widget.session.coachName,
        coachSport: '${widget.session.sport} Coach',
        coachImage: _image,
        coachPrice: _price,
        availableDays: _data.availableDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(topPadding),
                  _buildContentCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openBooking,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Text(
                      '${_price > 0 ? '$_price LE/hr  -  ' : ''}Book a session',
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        image: _headerImageProvider != null
            ? DecorationImage(
                image: _headerImageProvider!,
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.18),
              AppColors.deepBlue.withValues(alpha: 0.84),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'STEP 2 / 3',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data.sport.toUpperCase() +
                      (_locations.isNotEmpty
                          ? '  ·  ${_locations.first.toUpperCase()}'
                          : ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _data.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_rating.toStringAsFixed(1)} ($_reviewCount)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('-', style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 10),
                    Text(
                      _price > 0 ? '$_price LE/hr' : 'Price not set',
                      style: const TextStyle(
                        color: AppColors.lightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
            if (_selectedTab == 0) ...[
              _buildSectionLabel('ABOUT'),
              const SizedBox(height: 12),
              _buildBio(),
              const SizedBox(height: 26),
              _buildSectionLabel('STATS'),
              const SizedBox(height: 12),
              _buildStats(),
              const SizedBox(height: 26),
              _buildSectionLabel('ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildAchievements(),
              const SizedBox(height: 26),
              _buildSectionLabel('LOCATIONS'),
              const SizedBox(height: 12),
              _buildLocations(),
            ] else ...[
              _buildSectionLabel('REVIEWS'),
              const SizedBox(height: 12),
              _buildReviews(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'About',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _TabButton(
            label: 'Reviews',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF9AA9C6),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _StatCard(value: '$_totalStudents', label: 'Students'),
        const SizedBox(width: 10),
        _StatCard(value: '$_totalSessions', label: 'Sessions'),
        const SizedBox(width: 10),
        _StatCard(value: _hoursTaught.toStringAsFixed(0), label: 'Hours'),
      ],
    );
  }

  Widget _buildBio() {
    if (_bio.trim().isEmpty) {
      return const Text(
        'No bio yet',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      );
    }

    final truncated = _bio.length > 120 ? '${_bio.substring(0, 120)}...' : _bio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _bioExpanded ? _bio : truncated,
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            color: Color(0xFF4C5C7D),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (_bio.length > 120)
          GestureDetector(
            onTap: () => setState(() => _bioExpanded = !_bioExpanded),
            child: Text(
              _bioExpanded ? 'Read Less' : 'Read More',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievements() {
    if (_achievements.isEmpty) {
      return _EmptyPanel(
        icon: Icons.emoji_events_outlined,
        text: 'No achievements yet',
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: _achievements.map((a) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(a.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                a.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                a.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviews() {
    if (_reviews.isEmpty) {
      return _EmptyPanel(
        icon: Icons.star_outline_rounded,
        text: 'No reviews yet',
      );
    }

    return Column(
      children: _reviews.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                size: 14,
                                color: i < r.rating
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      r.date,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.comment,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocations() {
    if (_locations.isEmpty) {
      return _EmptyPanel(
        icon: Icons.location_on_outlined,
        text: 'No locations added yet',
      );
    }

    return Column(
      children: _locations.map((location) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDE5F4)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.lightBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Available training location',
                      style: TextStyle(
                        color: Color(0xFF6C7897),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDE5F4)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6C7897),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.deepBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6C7897),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyPanel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE5F4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9AA9C6), size: 22),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
