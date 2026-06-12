import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:maranny_two/features/messages/presentation/screens/chat_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cairo_time.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../data/repositories/reviews_payments_repository.dart';
import '../utils/bookings_refresh_notifier.dart';
import 'rate_coach_screen.dart';
import 'session_info_screen.dart';

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
            data
                .where((booking) => booking.isReviewed)
                .map((booking) => booking.bookingID),
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
    return scheduledAt.isBefore(CairoTime.now());
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

  int _coachUserId(BookingModel booking) {
    return booking.coach.userID ?? booking.coach.coachID;
  }

  Future<void> _openBookingDetails(BookingModel booking) async {
    BookingModel bookingDetails = booking;

    try {
      bookingDetails = await _repo.getBookingById(booking.bookingID);
    } catch (_) {
      bookingDetails = booking;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionInfoScreen(booking: bookingDetails),
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
        const SnackBar(
          content: Text('This session has already been reviewed.'),
        ),
      );
      return;
    }

    try {
      final existingReview = await _reviewsRepository.getBookingReview(
        booking.bookingID,
      );
      if (!mounted) return;
      if (existingReview != null) {
        setState(() {
          _reviewedBookingIds.add(booking.bookingID);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This session has already been reviewed.'),
          ),
        );
        return;
      }
    } catch (_) {}

    if (!mounted) return;

    final reviewed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RateSessionScreen(
          bookingId: booking.bookingID,
          sessionId: booking.session.sessionID,
          coachId: booking.coach.coachID,
          coachName: booking.coach.name,
          sportName: booking.session.sportName,
          isReviewed:
              _reviewedBookingIds.contains(booking.bookingID) ||
              booking.isReviewed,
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

  Future<void> _openMessageCoach(BookingModel booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: _coachUserId(booking),
          name: booking.coach.name,
          isOnline: false,
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 18),
                      _tabs(
                        upcomingCount: upcoming.length,
                        pendingCount: pending.length,
                        pastCount: past.length,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _stateMessage(
                    title: 'Could not load bookings',
                    subtitle: 'Tap to retry.',
                    onTap: _loadBookings,
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _stateMessage(
                    title: _selectedTabIndex == 0
                        ? 'No upcoming bookings yet'
                        : _selectedTabIndex == 1
                        ? 'No pending bookings yet'
                        : 'No past sessions yet',
                    subtitle: _selectedTabIndex == 0
                        ? 'Book a coach and your confirmed sessions will appear here.'
                        : 'Pull down to refresh anytime.',
                    onTap: _selectedTabIndex == 0
                        ? widget.onBookAnotherCoach
                        : _loadBookings,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, index) => _bookingCard(filtered[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR SESSIONS',
                style: TextStyle(
                  color: Color(0xFF9AA9C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bookings.',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: widget.onBookAnotherCoach,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.lightBlue,
            foregroundColor: AppColors.deepBlue,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            '+ Book',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _tabs({
    required int upcomingCount,
    required int pendingCount,
    required int pastCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _tabButton('Upcoming', upcomingCount, 0),
          _tabButton('Pending', pendingCount, 1),
          _tabButton('Past', pastCount, 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int count, int index) {
    final active = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.deepBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            '$label · $count',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF657393),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
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
    final scheduledAt =
        booking.scheduledDateTime ?? DateTime.tryParse(session.sessionDate);
    final statusStyle = _statusStyle(booking);
    final price = _priceText(session.price ?? booking.amount);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE5F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _coachAvatar(coach.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${session.sportName} · ${_cleanLocation(session.location)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6C7897),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusPill(statusStyle),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduledAt == null
                            ? '${_formatDate(session.sessionDate)} · ${_formatTime(session.startTime)}'
                            : '${_formatFriendlyDate(scheduledAt)} · ${_formatClock(scheduledAt, session.startTime)}',
                        style: const TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cleanLocation(session.location),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6C7897),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _durationText(session),
                      style: const TextStyle(
                        color: Color(0xFF6C7897),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _actionChip(
                  text: past ? 'Rate coach' : 'Message coach',
                  icon: past ? Icons.star_rounded : Icons.chat_bubble_rounded,
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
                            await _openMessageCoach(booking);
                          }

                          if (mounted) {
                            setState(
                              () => _activeButton.remove(booking.bookingID),
                            );
                          }
                        },
                ),
                const SizedBox(width: 10),
                _actionChip(
                  text: 'Session info',
                  icon: Icons.info_rounded,
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
          ),
        ],
      ),
    );
  }

  Widget _coachAvatar(String name) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _statusPill(_BookingStatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: style.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required String text,
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.deepBlue
                : enabled
                ? const Color(0xFFEAF0FB)
                : const Color(0xFFF1F2F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? Colors.white
                    : enabled
                    ? AppColors.deepBlue
                    : const Color(0xFF9AA3B5),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : enabled
                        ? AppColors.deepBlue
                        : const Color(0xFF9AA3B5),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateMessage({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6C7897),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  _BookingStatusStyle _statusStyle(BookingModel booking) {
    final normalized = booking.normalizedStatus;
    if (normalized == 'confirmed' || normalized == 'completed') {
      return const _BookingStatusStyle(
        label: 'CONFIRMED',
        color: AppColors.confirmed,
        background: AppColors.successLight,
      );
    }
    if (normalized == 'pending') {
      return const _BookingStatusStyle(
        label: 'PENDING',
        color: AppColors.warning,
        background: AppColors.warningLight,
      );
    }
    return const _BookingStatusStyle(
      label: 'CANCELLED',
      color: AppColors.error,
      background: AppColors.errorLight,
    );
  }

  String _formatDate(String raw) {
    final parsed = CairoTime.parse(raw);
    if (parsed == null) return raw;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  String _formatFriendlyDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(String raw) {
    final value = raw.trim();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?(?:\s*(AM|PM))?$',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return value;

    var hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;
    final meridiem = match.group(3)?.toUpperCase();
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatClock(DateTime scheduledAt, String fallbackRaw) {
    final raw = fallbackRaw.trim();
    if (raw.toLowerCase().contains('am') || raw.toLowerCase().contains('pm')) {
      return raw;
    }

    final hour = scheduledAt.hour;
    final minute = scheduledAt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final minutePart = minute == 0
        ? ''
        : ':${minute.toString().padLeft(2, '0')}';
    return '$displayHour$minutePart $period';
  }

  String _durationText(SessionModel session) {
    final start = _parseTimeOfDay(session.startTime);
    final end = _parseTimeOfDay(session.endTime);
    if (start == null || end == null) return '1 hr';

    var minutes =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    if (minutes <= 0) minutes += 24 * 60;
    if (minutes >= 60 && minutes % 60 == 0) {
      return '${minutes ~/ 60} hr';
    }
    return '$minutes min';
  }

  TimeOfDay? _parseTimeOfDay(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final amPm = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value);
    if (amPm != null) {
      var hour = int.tryParse(amPm.group(1) ?? '') ?? 0;
      final minute = int.tryParse(amPm.group(2) ?? '0') ?? 0;
      final period = (amPm.group(3) ?? '').toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].substring(0, 2));
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _priceText(double? price) {
    if (price == null || price <= 0) return 'Price TBD';
    return '${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)} LE';
  }

  String _cleanLocation(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Location TBD' : trimmed;
  }
}

class _BookingStatusStyle {
  final String label;
  final Color color;
  final Color background;

  const _BookingStatusStyle({
    required this.label,
    required this.color,
    required this.background,
  });
}
