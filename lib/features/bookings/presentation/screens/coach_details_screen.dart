import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/booking_session_model.dart';
import '../../domain/models/coach_data_model.dart';
import '../widgets/book_session_sheet.dart';

class CoachDetailsScreen extends StatefulWidget {
  final BookingSessionModel session;
  final String image;
  // ✅ Optional customized coach data — if null uses defaults
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

  // ✅ ALWAYS resolve from allCoachesData by name — same data everywhere in app
  late final CoachData _data;

  @override
  void initState() {
    super.initState();
    // Look up by exact name, then by first name, then fall back to first coach
    _data = allCoachesData.firstWhere(
          (c) => c.name == widget.session.coachName,
      orElse: () => allCoachesData.firstWhere(
            (c) => c.name.startsWith(widget.session.coachName.split(' ').first),
        orElse: () => allCoachesData.first,
      ),
    );
  }

  // All data comes from _data — guaranteed consistent everywhere
  String get _bio => _data.bio;
  int get _totalStudents => _data.totalStudents;
  int get _totalSessions => _data.totalSessions;
  double get _hoursTaught => _data.hoursTaught;
  double get _rating => _data.rating;
  int get _reviewCount => _data.reviewCount;
  int get _price => _data.price;
  String get _image => _data.image;
  String get _location => '${_data.location}'; // from coach_data_model
  List<CoachAchievement> get _achievements => _data.achievements;
  List<CoachReview> get _reviews => _data.reviews;

  void _openBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => BookSessionSheet(
        coachName: widget.session.coachName,
        coachSport: '${widget.session.sport} Coach',
        coachImage: _image,
        coachPrice: _price, // ✅ uses bulletproof _price getter
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(topPadding),
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 16),
                  _buildSection('Bio', _buildBio()),
                  _buildSection('Achievements', _buildAchievements()),
                  _buildSection('Reviews', _buildReviews()),
                  _buildSection('Coach Certifications', _buildCertifications()),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Book Session button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _openBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Book Session',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _image.isNotEmpty
                    ? Image.asset(_image,
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarBox())
                    : _avatarBox(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.session.coachName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${widget.session.sport} Coach',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(_location,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('$_rating ($_reviewCount reviewers)',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ FIX: use _price (from coachData) in LE, not hardcoded $25
                  Text('$_price LE/hr',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const Text('per session',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarBox() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.session.coachName.isNotEmpty
              ? widget.session.coachName[0].toUpperCase()
              : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(icon: Icons.people, iconColor: Colors.purple,
              value: '$_totalStudents', label: 'Total Students'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.gps_fixed, iconColor: Colors.red,
              value: '$_totalSessions', label: 'Total Sessions'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.timer, iconColor: Colors.blue,
              value: '$_hoursTaught', label: 'Hours Taught'),
        ],
      ),
    );
  }

  Widget _buildBio() {
    final truncated = _bio.length > 120 ? '${_bio.substring(0, 120)}...' : _bio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_bioExpanded ? _bio : truncated,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _bioExpanded = !_bioExpanded),
          child: Text(_bioExpanded ? 'Read Less' : 'Read More',
              style: const TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: _achievements.map((a) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(a.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(a.title, textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(a.subtitle, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildReviews() {
    return Column(
      children: _reviews.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const CircleAvatar(radius: 20, child: Icon(Icons.person, size: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(children: List.generate(5, (i) => Icon(Icons.star,
                        size: 14,
                        color: i < r.rating ? Colors.orange : Colors.grey.shade300))),
                  ],
                )),
                Text(r.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
              const SizedBox(height: 8),
              Text(r.comment,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCertifications() {
    return Row(
      children: [
        Expanded(child: _CertCard('assets/images/coach2.jpeg', 'Sports Management Degree')),
        const SizedBox(width: 12),
        Expanded(child: _CertCard('assets/images/coach2.jpeg', 'Fitness Training Certificate')),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.iconColor,
    required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final String imagePath;
  final String title;
  const _CertCard(this.imagePath, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(imagePath,
                width: double.infinity, height: 100, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    height: 100, color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.workspace_premium,
                        size: 40, color: Colors.grey)))),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
