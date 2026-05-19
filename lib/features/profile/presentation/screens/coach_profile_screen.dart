import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../bookings/data/models/bookings_models.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../bookings/data/models/reviews_payments_models.dart';
import '../../../bookings/data/repositories/reviews_payments_repository.dart';
import '../../../bookings/presentation/utils/bookings_refresh_notifier.dart';
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
  final BookingsRepository _bookingsRepository = BookingsRepository();

  bool _isLoading = true;
  bool _isBioExpanded = false;

  String name = 'Coach';
  String email = '';
  String phone = 'Not added yet';
  String location = 'Not added yet';
  String bio = 'No bio yet';
  String price = '0 LE';
  String sportsLabel = 'Coach';
  String verificationStatus = 'Pending';
  String experienceLabel = 'Not added yet';
  String genderLabel = 'Not added yet';
  String ageLabel = 'Not added yet';
  String availabilityLabel = 'Not added yet';
  String certificationLabel = 'No certifications yet';
  String totalReviewsValue = '0';
  String totalClientsValue = '0';
  String totalSessionsValue = '0';
  String pendingRequestsValue = '0';
  String? imageUrl;
  List<ReviewModel> _reviews = const <ReviewModel>[];
  double _averageRating = 0;
  int _totalReviews = 0;

  bool get _shouldShowVerificationNotice {
    final normalized = verificationStatus.trim().toLowerCase();
    return normalized.isEmpty ||
        (normalized != 'verified' &&
            normalized != 'approved' &&
            normalized != 'accepted');
  }

  @override
  void initState() {
    super.initState();
    BookingsRefreshNotifier.changes.addListener(_handleBookingsRefresh);
    _loadCoach();
  }

  @override
  void dispose() {
    BookingsRefreshNotifier.changes.removeListener(_handleBookingsRefresh);
    super.dispose();
  }

  void _handleBookingsRefresh() {
    if (mounted) {
      _loadCoach();
    }
  }

  Future<void> _loadCoach() async {
    try {
      final UserModel user = await _authRepository.getCurrentUser();
      final coachSetup = await _profileRepository.getMyCoachSetup();
      final coachProfile = await _profileRepository.getCoachProfile(
        coachSetup.coachId > 0 ? coachSetup.coachId : user.id,
      );
      final results = await Future.wait<Object?>([
        _loadCoachReviewsFallback(coachSetup.coachId),
        _loadCoachBookingsFallback(),
      ]);
      final reviewsPage = results[0] as PaginatedReviews?;
      final coachBookings =
          (results[1] as List<BookingModel>?) ?? const <BookingModel>[];

      final resolvedBio = coachSetup.bio?.trim().isNotEmpty == true
          ? coachSetup.bio!.trim()
          : (coachProfile.resolvedBio?.trim() ?? '');
      final resolvedLocation =
          coachSetup.resolvedLocation?.trim().isNotEmpty == true
          ? coachSetup.resolvedLocation!.trim()
          : (coachProfile.resolvedLocation?.trim() ?? '');
      final resolvedPrice = _formatPrice(
        coachSetup.sessionPrice ?? coachProfile.resolvedPrice,
      );
      final averageRating =
          reviewsPage?.averageRating ?? coachProfile.avgRating;
      final totalReviews = reviewsPage?.totalCount ?? coachProfile.totalReviews;
      final profileSports = coachProfile.sports
          .map((sport) => sport.name.trim())
          .where((sport) => sport.isNotEmpty)
          .toList(growable: false);
      final setupSports = coachSetup.sportsLabel == 'Coach'
          ? <String>[]
          : coachSetup.sportsLabel.split(' | ');
      final joinedSports = [...setupSports, ...profileSports]
          .where((sport) => sport.trim().isNotEmpty && sport != 'Coach')
          .toSet()
          .join(' | ');
      final experienceYears = coachSetup.experienceYears ?? 0;
      final resolvedGender = _formatGender(
        coachSetup.gender ?? coachProfile.gender,
      );
      final resolvedAge = coachSetup.age ?? coachProfile.age;
      final availabilityDays = coachSetup.availableDays
          .map((day) => day.trim())
          .where((day) => day.isNotEmpty)
          .toList(growable: false);
      final availabilityText = availabilityDays.isEmpty
          ? 'Not added yet'
          : availabilityDays.join(', ');
      final certificationText =
          (coachSetup.certificateUrl?.trim().isNotEmpty ?? false)
          ? 'Certificate uploaded'
          : 'No certifications yet';
      final bookingStats = _buildBookingStats(coachBookings);

      developer.log(
        'CoachProfileScreen parsed fields -> '
        'name=${coachSetup.fullName}, '
        'sports=$joinedSports, '
        'bio=$resolvedBio, '
        'price=$resolvedPrice, '
        'location=$resolvedLocation, '
        'availability=$availabilityText, '
        'reviewsCount=$totalReviews, '
        'averageRating=$averageRating, '
        'bookingStats=$bookingStats',
        name: 'CoachProfileScreen',
      );

      if (!mounted) return;

      setState(() {
        name = coachSetup.fullName.trim().isNotEmpty
            ? coachSetup.fullName
            : coachProfile.name.trim().isNotEmpty
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
        sportsLabel = joinedSports.isNotEmpty ? joinedSports : 'No sports yet';
        verificationStatus = coachSetup.verificationStatus;
        experienceLabel = experienceYears > 0
            ? '$experienceYears year${experienceYears == 1 ? '' : 's'} experience'
            : 'Not added yet';
        genderLabel = resolvedGender;
        ageLabel = resolvedAge != null && resolvedAge > 0
            ? '$resolvedAge years old'
            : 'Not added yet';
        availabilityLabel = availabilityText;
        certificationLabel = certificationText;
        totalReviewsValue = totalReviews.toString();
        totalClientsValue = bookingStats.totalClients.toString();
        totalSessionsValue = bookingStats.totalSessions.toString();
        pendingRequestsValue = bookingStats.pendingRequests.toString();
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
      if (coachId <= 0) {
        return null;
      }
      try {
        return await _reviewsRepository.getCoachReviews(coachId);
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<BookingModel>> _loadCoachBookingsFallback() async {
    try {
      return await _bookingsRepository.getCoachBookings();
    } catch (error, stackTrace) {
      developer.log(
        'CoachProfileScreen failed to load coach bookings',
        name: 'CoachProfileScreen',
        error: error,
        stackTrace: stackTrace,
      );
      return const <BookingModel>[];
    }
  }

  _CoachBookingStats _buildBookingStats(List<BookingModel> bookings) {
    final activeOrCompleted = bookings
        .where(
          (booking) =>
              isPendingBookingStatus(booking.status) ||
              isConfirmedBookingStatus(booking.status) ||
              isCompletedBookingStatus(booking.status),
        )
        .toList(growable: false);
    final uniqueClientIds = <int>{};
    var fallbackNamedClients = 0;

    for (final booking in activeOrCompleted) {
      final client = booking.client;
      if (client != null && client.userID > 0) {
        uniqueClientIds.add(client.userID);
      } else if ((client?.name.trim().isNotEmpty ?? false) &&
          client!.name != 'Client') {
        fallbackNamedClients++;
      }
    }

    return _CoachBookingStats(
      totalClients: uniqueClientIds.isNotEmpty
          ? uniqueClientIds.length
          : fallbackNamedClients,
      totalSessions: activeOrCompleted
          .where(
            (booking) =>
                isConfirmedBookingStatus(booking.status) ||
                isCompletedBookingStatus(booking.status),
          )
          .length,
      pendingRequests: activeOrCompleted
          .where((booking) => isPendingBookingStatus(booking.status))
          .length,
    );
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

  String _formatGender(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Not added yet';
    }
    return normalized[0].toUpperCase() + normalized.substring(1).toLowerCase();
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
        backgroundColor: Color(0xFFF3F7FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_shouldShowVerificationNotice) _buildVerificationNotice(),
            _buildStats(),
            _buildSectionTitle('Bio'),
            _buildBioCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Information'),
            _buildContactCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Coaching Details'),
            _buildCoachingDetails(),
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
            _simpleInfoCard(certificationLabel),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COACH PROFILE',
                style: TextStyle(
                  color: Color(0xFF9AA9C6),
                  fontSize: 11,
                  letterSpacing: 2.3,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.deepBlue.withValues(alpha: 0.13),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepBlue.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: _buildProfileImage(),
                          ),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: AppColors.deepBlue,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            fontFamily: 'Poppins',
                            color: AppColors.deepBlue,
                          ),
                        ),
                        const SizedBox(height: 9),
                        _headerMetaLine(
                          Icons.sports_soccer_outlined,
                          sportsLabel == 'No sports yet'
                              ? 'Training not selected yet'
                              : sportsLabel,
                        ),
                        const SizedBox(height: 7),
                        _headerMetaLine(Icons.location_on_outlined, location),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Inter',
                                color: AppColors.deepBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($_totalReviews reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF6C7897),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$price / session',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerMetaLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepBlue.withValues(alpha: 0.65), size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBCEEFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F3A93).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFD6F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.primaryBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your coach account is currently under review.',
                  style: TextStyle(
                    color: Color(0xFF142450),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Please note that account verification may take between 24 to 48 hours. You will be notified once your account has been approved.',
                  style: TextStyle(
                    color: Color(0xFF52698F),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
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
            value: totalClientsValue,
            label: 'Clients',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.gps_fixed,
            iconColor: Colors.red,
            value: totalSessionsValue,
            label: 'Sessions',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.timer,
            iconColor: Colors.blue,
            value: pendingRequestsValue,
            label: 'Pending',
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
      margin: const EdgeInsets.symmetric(horizontal: 18),
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
              color: Color(0xFF6C7897),
              height: 1.45,
              fontWeight: FontWeight.w600,
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
                  color: AppColors.deepBlue,
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
      margin: const EdgeInsets.symmetric(horizontal: 18),
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

  Widget _buildCoachingDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _achievementText('Sports: $sportsLabel'),
          const SizedBox(height: 6),
          _achievementText('Verification: $verificationStatus'),
          const SizedBox(height: 6),
          _achievementText('Experience: $experienceLabel'),
          const SizedBox(height: 6),
          _achievementText('Gender: $genderLabel'),
          const SizedBox(height: 6),
          _achievementText('Age: $ageLabel'),
          const SizedBox(height: 6),
          _achievementText('Availability: $availabilityLabel'),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      return Image.network(
        imageUrl!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarBox(),
      );
    }

    return _avatarBox();
  }

  Widget _avatarBox() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF7),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
          color: AppColors.deepBlue,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: Color(0xFF6C7897),
                fontWeight: FontWeight.w700,
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
        Icon(icon, color: AppColors.deepBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w700,
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

  Widget _simpleInfoCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: _emptyText(text),
    );
  }

  Widget _achievementText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.deepBlue,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFD7E0F2)),
      boxShadow: [
        BoxShadow(
          color: AppColors.deepBlue.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 9),
        ),
      ],
    );
  }
}

class _CoachBookingStats {
  final int totalClients;
  final int totalSessions;
  final int pendingRequests;

  const _CoachBookingStats({
    required this.totalClients,
    required this.totalSessions,
    required this.pendingRequests,
  });

  @override
  String toString() {
    return '{totalClients: $totalClients, totalSessions: $totalSessions, pendingRequests: $pendingRequests}';
  }
}
