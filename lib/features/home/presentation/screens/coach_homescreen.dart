import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/network/token_storage.dart';
import '../../../../../core/widgets/app_side_menu.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';
import '../../../bookings/data/models/bookings_models.dart';
import '../../../bookings/data/models/reviews_payments_models.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../bookings/data/repositories/reviews_payments_repository.dart';
import '../../../bookings/presentation/screens/upcoming_pending.dart';
import '../../../bookings/presentation/screens/session_info_screen.dart';
import '../../../bookings/presentation/utils/bookings_refresh_notifier.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../reviews/presentation/screens/all_reviews_screen.dart';
import '../widgets/SessionCard.dart';
import '../widgets/header.dart';
import '../widgets/pending_request_card.dart';
import '../widgets/review_card.dart';

class CoachHomeScreen extends StatefulWidget {
  final VoidCallback onAuthRequired;

  const CoachHomeScreen({super.key, required this.onAuthRequired});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ReviewsRepository _reviewsRepository = ReviewsRepository();
  final BookingsRepository _bookingsRepository = BookingsRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  String _userName = 'Coach';
  String _verificationStatus = 'Pending';
  bool _isLoadingBookings = true;
  List<BookingModel> _coachBookings = const <BookingModel>[];
  List<ReviewModel> _recentReviews = const <ReviewModel>[];

  bool get _shouldShowVerificationNotice {
    final normalized = _verificationStatus.trim().toLowerCase();
    return normalized.isEmpty ||
        (normalized != 'verified' &&
            normalized != 'approved' &&
            normalized != 'accepted');
  }

  @override
  void initState() {
    super.initState();
    BookingsRefreshNotifier.changes.addListener(_handleBookingsRefresh);
    _loadUserName();
    _loadVerificationStatus();
    _loadBookings();
    _loadRecentReviews();
  }

  @override
  void dispose() {
    BookingsRefreshNotifier.changes.removeListener(_handleBookingsRefresh);
    super.dispose();
  }

  void _handleBookingsRefresh() {
    if (mounted) {
      _loadBookings();
    }
  }

  Future<void> _loadUserName() async {
    final displayName = await TokenStorage.getDisplayName();

    if (!mounted) return;

    setState(() {
      _userName = displayName != null && displayName.trim().isNotEmpty
          ? displayName.trim()
          : 'Coach';
    });
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final setup = await _profileRepository.getMyCoachSetup();
      if (!mounted) return;
      setState(() {
        _verificationStatus = setup.verificationStatus;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verificationStatus = 'Pending';
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadVerificationStatus(),
      _loadBookings(),
      _loadRecentReviews(),
    ]);
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });

    try {
      final bookings = await _bookingsRepository.getCoachBookings();
      developer.log(
        'CoachHomeScreen bookings -> total=${bookings.length}',
        name: 'CoachHomeScreen',
      );

      if (!mounted) return;
      setState(() {
        _coachBookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _coachBookings = const <BookingModel>[];
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _loadRecentReviews() async {
    try {
      final reviewsPage = await _reviewsRepository.getMyCoachReviews(
        pageSize: 10,
      );
      if (!mounted) {
        return;
      }
      developer.log(
        'CoachHomeScreen recent reviews -> count=${reviewsPage.reviews.length} averageRating=${reviewsPage.averageRating}',
        name: 'CoachHomeScreen',
      );
      setState(() {
        _recentReviews = reviewsPage.reviews.take(2).toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _recentReviews = const <ReviewModel>[];
      });
    }
  }

  bool _isPending(BookingModel booking) =>
      isPendingBookingStatus(booking.status);

  bool _isConfirmed(BookingModel booking) =>
      isConfirmedBookingStatus(booking.status) ||
      isCompletedBookingStatus(booking.status);

  bool _isToday(BookingModel booking) {
    final scheduledAt = booking.scheduledDateTime;
    if (scheduledAt == null) return false;
    final local = scheduledAt.isUtc ? scheduledAt.toLocal() : scheduledAt;
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  List<BookingModel> get _todaysSchedule =>
      _coachBookings
          .where((booking) => _isConfirmed(booking) && _isToday(booking))
          .toList()
        ..sort((a, b) {
          final first = a.scheduledDateTime ?? DateTime.now();
          final second = b.scheduledDateTime ?? DateTime.now();
          return first.compareTo(second);
        });

  List<BookingModel> get _pendingRequests =>
      _coachBookings.where(_isPending).toList()..sort((a, b) {
        final first = a.scheduledDateTime ?? DateTime.now();
        final second = b.scheduledDateTime ?? DateTime.now();
        return first.compareTo(second);
      });

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

  String _formatDate(BookingModel booking) {
    final scheduledAt =
        booking.scheduledDateTime ??
        DateTime.tryParse(booking.session.sessionDate);
    if (scheduledAt == null) {
      return booking.session.sessionDate;
    }
    return '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
  }

  String _formatTimeRange(BookingModel booking) {
    return '${booking.session.startTime} - ${booking.session.endTime}';
  }

  String _scheduleStatus(BookingModel booking) {
    final normalized = normalizeBookingStatus(booking.status);
    if (normalized == 'confirmed' || normalized == 'completed') {
      return 'Confirmed';
    }
    if (normalized == 'pending') {
      return 'Pending';
    }
    return booking.status;
  }

  String _clientName(BookingModel booking) {
    final name = booking.client?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Client';
  }

  Future<void> _approveBooking(BookingModel booking) async {
    try {
      await _bookingsRepository.approveBooking(booking.bookingID);
      BookingsRefreshNotifier.notifyUpdated();
      await _loadBookings();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking approved')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve booking')),
      );
    }
  }

  Future<void> _declineBooking(BookingModel booking) async {
    try {
      await _bookingsRepository.declineBooking(booking.bookingID);
      BookingsRefreshNotifier.notifyUpdated();
      await _loadBookings();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking declined')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to decline booking')),
      );
    }
  }

  void _confirmDecline(BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Request'),
        content: const Text('Are you sure you want to decline this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _declineBooking(booking);
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F7FF),
      drawer: AppSideMenu(
        userName: _userName,
        userType: 'coach',
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoachHomeHeader(
                userName: _userName,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                todaySessionsCount: _todaysSchedule.length,
                pendingRequestsCount: _pendingRequests.length,
                recentReviewsCount: _recentReviews.length,
                isVerified: !_shouldShowVerificationNotice,
              ),
              if (_shouldShowVerificationNotice)
                const _CoachVerificationNotice(),
              _SectionTitleWithViewAll(
                title: "Today's Schedule",
                onViewAll: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpcomingScreen()),
                  );
                  _loadBookings();
                },
              ),
              if (_isLoadingBookings)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_todaysSchedule.isEmpty)
                _emptyCard('No sessions scheduled today')
              else
                ..._todaysSchedule
                    .take(3)
                    .map(
                      (booking) => SessionCard(
                        name: _clientName(booking),
                        sport: booking.session.sportName,
                        time: _formatTimeRange(booking),
                        location: booking.session.location.trim().isEmpty
                            ? 'Location TBD'
                            : booking.session.location,
                        status: _scheduleStatus(booking),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SessionInfoScreen(booking: booking),
                          ),
                        ),
                      ),
                    ),
              _SectionTitleWithViewAll(
                title: 'Pending Requests',
                onViewAll: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpcomingScreen(initialTabIndex: 1),
                    ),
                  );
                  _loadBookings();
                },
              ),
              if (_isLoadingBookings)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_pendingRequests.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE1E9F8)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F6FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFDCE7FA)),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 36,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have no pending requests at the moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ..._pendingRequests
                    .take(2)
                    .map(
                      (booking) => PendingRequestCard(
                        name: _clientName(booking),
                        sport: booking.session.sportName,
                        date:
                            '${_formatDate(booking)} at ${booking.session.startTime}',
                        status: 'Pending',
                        onAccept: () => _approveBooking(booking),
                        onDecline: () => _confirmDecline(booking),
                      ),
                    ),
              _SectionTitleWithViewAll(
                title: 'Recent Reviews',
                onViewAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllReviewsScreen()),
                ),
              ),
              if (_recentReviews.isEmpty)
                _emptyCard('No reviews yet')
              else
                ..._recentReviews.map(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E9F8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

class _SectionTitleWithViewAll extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionTitleWithViewAll({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: AppColors.primaryBlue,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All ->',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachVerificationNotice extends StatelessWidget {
  const _CoachVerificationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
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
              color: Color(0xFF1F3A93),
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
}
