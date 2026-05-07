import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:maranny_two/features/messages/presentation/screens/chat_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/reviews_payments_repository.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../domain/models/booking_session_model.dart';
import '../../domain/models/coach_data_model.dart';
import '../../presentation/screens/coach_details_screen.dart';
import 'rate_coach_screen.dart';
import '../utils/bookings_refresh_notifier.dart';

class BookingsScreen extends StatefulWidget {
  final VoidCallback onMessageTap;
  final VoidCallback onBookAnotherCoach;

  const BookingsScreen({
    super.key,
    required this.onMessageTap,
    required this.onBookAnotherCoach,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingsRepository _repo = BookingsRepository();
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String? _error;

  List<BookingModel> _bookings = [];
  final Map<int, String?> _activeButton = {};
  final Set<int> _reviewedBookingIds = <int>{};

  @override
  void initState() {
    super.initState();
    BookingsRefreshNotifier.changes.addListener(_handleRefreshSignal);
    _loadBookings();
  }

  @override
  void dispose() {
    BookingsRefreshNotifier.changes.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void _handleRefreshSignal() {
    if (mounted) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getMyBookings();

      if (!mounted) return;

      _logClientBookingBuckets(data);

      setState(() {
        _bookings = data;
        _reviewedBookingIds
          ..clear()
          ..addAll(
            data.where((booking) => booking.isReviewed).map((booking) => booking.bookingID),
          );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load bookings';
        _isLoading = false;
      });
    }
  }

  bool _isPending(BookingModel booking) =>
      isPendingBookingStatus(booking.status);

  bool _isConfirmedOrCompleted(BookingModel booking) =>
      isConfirmedBookingStatus(booking.status) ||
      isCompletedBookingStatus(booking.status);

  bool _isPast(BookingModel booking) {
    final scheduledAt = booking.scheduledDateTime;
    if (scheduledAt == null) {
      return false;
    }
    return scheduledAt.isBefore(DateTime.now());
  }

  bool _isUpcoming(BookingModel booking) =>
      !_isPast(booking) && _isConfirmedOrCompleted(booking);

  bool _isPastSession(BookingModel booking) =>
      _isPast(booking) && _isConfirmedOrCompleted(booking);

  void _logClientBookingBuckets(List<BookingModel> bookings) {
    developer.log(
      'Client bookings categorized -> '
      'pending=${bookings.where(_isPending).map((b) => _bookingLogMap(b)).toList(growable: false)} '
      'upcoming=${bookings.where(_isUpcoming).map((b) => _bookingLogMap(b)).toList(growable: false)} '
      'past=${bookings.where(_isPastSession).map((b) => _bookingLogMap(b)).toList(growable: false)}',
      name: 'BookingsScreen',
    );
  }

  Map<String, dynamic> _bookingLogMap(BookingModel booking) => {
    'bookingId': booking.bookingID,
    'status': booking.status,
    'normalizedStatus': booking.normalizedStatus,
    'sessionDate': booking.session.sessionDate,
    'startTime': booking.session.startTime,
    'scheduledAt': booking.session.scheduledAt,
    'parsedDateTime': booking.scheduledDateTime?.toIso8601String(),
  };

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return raw;
    }
  }

  String _formatTime(String raw) {
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw;
  }

  int _coachUserId(BookingModel booking) {
    return booking.coach.coachID;
  }

  CoachData _coachDataFromBooking(BookingModel booking) {
    final session = booking.session;
    final coach = booking.coach;

    return CoachData(
      name: coach.name,
      sport: session.sportName,
      location: session.location,
      image: '',
      availableDays: const [],
      rating: coach.avgRating,
      reviewCount: 0,
      price: 0,
      bio: '',
      totalStudents: 0,
      totalSessions: 0,
      hoursTaught: 0,
      achievements: const [],
      reviews: const [],
    );
  }

  Future<void> _openBookingDetails(BookingModel booking) async {
    BookingModel bookingDetails = booking;

    try {
      bookingDetails = await _repo.getBookingById(booking.bookingID);
    } catch (_) {
      bookingDetails = booking;
    }

    if (!mounted) return;

    final detailsSession = BookingSessionModel(
      id: bookingDetails.bookingID.toString(),
      coachUserId: _coachUserId(bookingDetails),
      coachName: bookingDetails.coach.name,
      sport: bookingDetails.session.sportName,
      location: bookingDetails.session.location,
      date:
          bookingDetails.scheduledDateTime ??
          DateTime.tryParse(bookingDetails.session.sessionDate) ??
          DateTime.now(),
      isPast: _isPastSession(bookingDetails),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          session: detailsSession,
          image: '',
          coachData: _coachDataFromBooking(bookingDetails),
        ),
      ),
    );
  }

  Future<void> _openRateScreen(BookingModel booking) async {
    developer.log(
      'Rate Coach tapped -> bookingId=${booking.bookingID} sessionId=${booking.session.sessionID} coachId=${booking.coach.coachID} coachName=${booking.coach.name}',
      name: 'BookingsScreen',
    );

    if (_reviewedBookingIds.contains(booking.bookingID) || booking.isReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This session has already been reviewed.')),
      );
      return;
    }

    try {
      final existingReview = await _reviewsRepository.getBookingReview(
        booking.bookingID,
      );
      if (!mounted) {
        return;
      }
      if (existingReview != null) {
        setState(() {
          _reviewedBookingIds.add(booking.bookingID);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This session has already been reviewed.')),
        );
        return;
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    final reviewed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RateSessionScreen(
          bookingId: booking.bookingID,
          sessionId: booking.session.sessionID,
          coachId: booking.coach.coachID,
          coachName: booking.coach.name,
          sportName: booking.session.sportName,
          isReviewed: _reviewedBookingIds.contains(booking.bookingID) || booking.isReviewed,
          onSubmitted: () {},
        ),
      ),
    );

    if (reviewed == true && mounted) {
      setState(() {
        _reviewedBookingIds.add(booking.bookingID);
      });
      await _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _bookings.where(_isPending).toList();
    final upcoming = _bookings.where(_isUpcoming).toList();
    final past = _bookings.where(_isPastSession).toList();
    final filtered = _selectedTabIndex == 0
        ? upcoming
        : _selectedTabIndex == 1
        ? pending
        : past;
    final isUpcomingTab = _selectedTabIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          _tabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBookings,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 220),
                        Center(
                          child: TextButton(
                            onPressed: _loadBookings,
                            child: Text(_error!),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: isUpcomingTab
                          ? filtered.length + 1
                          : filtered.length,
                      itemBuilder: (_, index) {
                        if (isUpcomingTab && index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: _primaryButton(
                              text: 'Book Another Coach',
                              onTap: widget.onBookAnotherCoach,
                            ),
                          );
                        }

                        if (filtered.isEmpty) {
                          return _emptyCard(
                            _selectedTabIndex == 0
                                ? 'No upcoming bookings yet'
                                : _selectedTabIndex == 1
                                ? 'No pending bookings yet'
                                : 'No past sessions yet',
                          );
                        }

                        return _bookingCard(filtered[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _tabButton(
            'Upcoming',
            _selectedTabIndex == 0,
            () => setState(() => _selectedTabIndex = 0),
          ),
          _tabButton(
            'Pending',
            _selectedTabIndex == 1,
            () => setState(() => _selectedTabIndex = 1),
          ),
          _tabButton(
            'Past Sessions',
            _selectedTabIndex == 2,
            () => setState(() => _selectedTabIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                color: active ? AppColors.primaryBlue : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              color: active ? AppColors.primaryBlue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final activeBtn = _activeButton[booking.bookingID];
    final session = booking.session;
    final coach = booking.coach;
    final past = _isPastSession(booking);
    final alreadyReviewed =
        booking.isReviewed || _reviewedBookingIds.contains(booking.bookingID);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coach.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              session.sportName,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(session.sessionDate)} • ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
            ),
            const SizedBox(height: 6),
            Text(
              booking.status,
              style: TextStyle(
                color:
                    booking.normalizedStatus == 'confirmed' ||
                        booking.normalizedStatus == 'completed'
                    ? Colors.green
                    : booking.normalizedStatus == 'pending'
                    ? Colors.orange
                    : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionButton(
                  text: past ? 'Rate Coach' : 'Message Coach',
                  isActive: activeBtn == 'message',
                  onTap: past && alreadyReviewed
                      ? null
                      : () async {
                    setState(
                      () => _activeButton[booking.bookingID] = 'message',
                    );

                    if (past) {
                      await _openRateScreen(booking);
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: _coachUserId(booking),
                            name: coach.name,
                            isOnline: false,
                          ),
                        ),
                      );
                    }

                    if (mounted) {
                      setState(() => _activeButton.remove(booking.bookingID));
                    }
                  },
                ),
                const SizedBox(width: 12),
                _actionButton(
                  text: 'Details',
                  isActive: activeBtn == 'details',
                  onTap: () async {
                    setState(
                      () => _activeButton[booking.bookingID] = 'details',
                    );
                    await _openBookingDetails(booking);

                    if (mounted) {
                      setState(() => _activeButton.remove(booking.bookingID));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? AppColors.primaryBlue
              : AppColors.disabledGray,
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _emptyCard(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 180),
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
