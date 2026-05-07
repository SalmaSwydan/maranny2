import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../bookings/data/models/reviews_payments_models.dart';
import '../../../bookings/data/repositories/reviews_payments_repository.dart';
import '../../../home/presentation/widgets/review_card.dart';
import '../../data/repositories/profile_repository.dart';
import 'edit_profile_screen.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  bool _isLoading = true;
  bool _isBioExpanded = false;

  String name = 'Coach';
  String email = '';
  String phone = 'Not added yet';
  String location = 'Not added yet';
  String bio = 'No bio yet';
  String price = '0 LE';
  String? imageUrl;
  List<ReviewModel> _reviews = const <ReviewModel>[];
  double _averageRating = 0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadCoach();
  }

  Future<void> _loadCoach() async {
    try {
      final UserModel user = await _authRepository.getCurrentUser();
      final coachProfile = await _profileRepository.getCoachProfile(user.id);
      final reviewsPage = await _loadCoachReviewsFallback(user.id);

      final resolvedBio = coachProfile.resolvedBio?.trim() ?? '';
      final resolvedLocation = coachProfile.resolvedLocation?.trim() ?? '';
      final resolvedPrice = _formatPrice(coachProfile.resolvedPrice);
      final averageRating = reviewsPage?.averageRating ?? coachProfile.avgRating;
      final totalReviews = reviewsPage?.totalCount ?? coachProfile.totalReviews;

      developer.log(
        'CoachProfileScreen parsed fields -> '
        'bio=$resolvedBio, '
        'price=$resolvedPrice, '
        'location=$resolvedLocation, '
        'reviewsCount=$totalReviews, '
        'averageRating=$averageRating',
        name: 'CoachProfileScreen',
      );

      if (!mounted) return;

      setState(() {
        name = coachProfile.name.trim().isNotEmpty
            ? coachProfile.name
            : (user.fullName.trim().isNotEmpty ? user.fullName : 'Coach');
        email = (coachProfile.email?.trim().isNotEmpty ?? false)
            ? coachProfile.email!
            : user.email;
        phone = (coachProfile.phoneNumber?.trim().isNotEmpty ?? false)
            ? coachProfile.phoneNumber!
            : 'Not added yet';
        location = resolvedLocation.isNotEmpty
            ? resolvedLocation
            : 'Not added yet';
        bio = resolvedBio.isNotEmpty ? resolvedBio : 'No bio yet';
        price = resolvedPrice;
        imageUrl = (coachProfile.profilePictureUrl?.trim().isNotEmpty ?? false)
            ? coachProfile.profilePictureUrl
            : user.profilePicture;
        _reviews = reviewsPage?.reviews ?? const <ReviewModel>[];
        _averageRating = averageRating;
        _totalReviews = totalReviews;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<PaginatedReviews?> _loadCoachReviewsFallback(int coachId) async {
    try {
      return await _reviewsRepository.getMyCoachReviews();
    } catch (_) {
      try {
        return await _reviewsRepository.getCoachReviews(coachId);
      } catch (_) {
        return null;
      }
    }
  }

  String _formatPrice(double? value) {
    if (value == null || value <= 0) {
      return '0 LE';
    }

    if (value == value.roundToDouble()) {
      return '${value.toInt()} LE';
    }

    return '${value.toStringAsFixed(2)} LE';
  }

  String _formatReviewTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    final difference = DateTime.now().difference(local);
    if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildStats(),
            _buildSectionTitle('Bio'),
            _buildBioCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Information'),
            _buildContactCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Achievements'),
            _buildAchievements(),
            const SizedBox(height: 24),
            _buildSectionTitle('Reviews'),
            if (_reviews.isEmpty)
              const ReviewCard(
                name: 'No reviews yet',
                review: 'Reviews will appear here after clients rate you.',
                timestamp: '',
                rating: 0,
              )
            else
              ..._reviews.map(
                (review) => ReviewCard(
                  name: review.clientName,
                  review: review.comment.isNotEmpty
                      ? review.comment
                      : 'No written comment provided.',
                  timestamp: _formatReviewTime(review.createdAt),
                  rating: review.rating.round().clamp(0, 5),
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('Coach Certifications'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _emptyText('No certifications yet'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF6FD3F5), Color(0xFF1F3A93)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                  if (updated == true) _loadCoach();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildProfileImage(),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Coach',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($_totalReviews reviewers)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$price / session',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.people,
            iconColor: Colors.purple,
            value: '0',
            label: 'Total Students',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.gps_fixed,
            iconColor: Colors.red,
            value: '0',
            label: 'Total Sessions',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.timer,
            iconColor: Colors.blue,
            value: '0.0',
            label: 'Hours Taught',
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    final shownBio = bio.trim().isEmpty ? 'No bio yet' : bio;
    final displayText = _isBioExpanded
        ? shownBio
        : (shownBio.length > 150
              ? '${shownBio.substring(0, 150)}...'
              : shownBio);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
            ),
          ),
          if (shownBio.length > 150) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
              child: Text(
                _isBioExpanded ? 'Read Less' : 'Read More',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildContactRow(
            Icons.email,
            email.isNotEmpty ? email : 'Not added yet',
          ),
          const Divider(height: 24),
          _buildContactRow(Icons.phone, phone),
          const Divider(height: 24),
          _buildContactRow(Icons.location_on, location),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _emptyText('No achievements yet'),
    );
  }

  Widget _buildProfileImage() {
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      return Image.network(
        imageUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarBox(),
      );
    }

    return _avatarBox();
  }

  Widget _avatarBox() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
        fontFamily: 'Inter',
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
