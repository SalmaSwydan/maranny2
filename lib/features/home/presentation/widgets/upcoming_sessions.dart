import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/data/models/bookings_models.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/domain/models/coach_data_model.dart';
import '../../../bookings/presentation/screens/coach_details_screen.dart';

class UpcomingSessionsSection extends StatefulWidget {
  final VoidCallback? onViewMore;

  const UpcomingSessionsSection({super.key, this.onViewMore});

  @override
  State<UpcomingSessionsSection> createState() => _UpcomingSessionsSectionState();
}

class _UpcomingSessionsSectionState extends State<UpcomingSessionsSection> {
  final BookingsRepository _bookingsRepository = BookingsRepository();
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _loadUpcomingBookings();
  }

  Future<List<BookingModel>> _loadUpcomingBookings() async {
    final bookings = await _bookingsRepository.getMyBookings();
    final now = DateTime.now();

    final upcoming = bookings.where((booking) {
      final normalizedStatus = booking.normalizedStatus;
      final isUpcomingStatus =
          normalizedStatus == 'approved' ||
          normalizedStatus == 'confirmed' ||
          normalizedStatus == 'completed';
      final scheduledAt = booking.scheduledDateTime;
      return isUpcomingStatus &&
          scheduledAt != null &&
          !scheduledAt.isBefore(now);
    }).toList()
      ..sort((a, b) {
        final first = a.scheduledDateTime ?? DateTime.now();
        final second = b.scheduledDateTime ?? DateTime.now();
        return first.compareTo(second);
      });

    return upcoming;
  }

  Future<void> _openBookingDetails(BookingModel booking) async {
    BookingModel bookingDetails = booking;

    try {
      bookingDetails = await _bookingsRepository.getBookingById(
        booking.bookingID,
      );
    } catch (_) {}

    if (!mounted) return;

    final session = BookingSessionModel(
      id: bookingDetails.bookingID.toString(),
      coachUserId: bookingDetails.coach.userID ?? bookingDetails.coach.coachID,
      sportId: bookingDetails.session.sportID,
      coachName: bookingDetails.coach.name,
      sport: bookingDetails.session.sportName,
      location: bookingDetails.session.location,
      date:
          bookingDetails.scheduledDateTime ??
          DateTime.tryParse(bookingDetails.session.sessionDate) ??
          DateTime.now(),
      isPast: false,
    );

    final coachData = CoachData(
      name: bookingDetails.coach.name,
      sport: bookingDetails.session.sportName,
      sportId: bookingDetails.session.sportID,
      location: bookingDetails.session.location,
      image: '',
      rating: bookingDetails.coach.avgRating,
      reviewCount: 0,
      price: 0,
      bio: '',
      totalStudents: 0,
      totalSessions: 0,
      hoursTaught: 0,
      achievements: const [],
      reviews: const [],
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          session: session,
          image: '',
          coachData: coachData,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _bookingsFuture = _loadUpcomingBookings();
    });
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';

    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTimeLabel(DateTime date, String fallback) {
    if (date.hour == 0 && date.minute == 0 && fallback.trim().isNotEmpty) {
      return fallback;
    }

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: FutureBuilder<List<BookingModel>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _StateCard(
                  message: 'Could not load upcoming sessions right now.',
                  actionLabel: 'Open bookings',
                  onTap: widget.onViewMore,
                );
              }

              final bookings = snapshot.data ?? const <BookingModel>[];
              if (bookings.isEmpty) {
                return _StateCard(
                  message: 'No upcoming sessions yet.',
                  actionLabel: 'Book a coach',
                  onTap: widget.onViewMore,
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final scheduledAt =
                      booking.scheduledDateTime ??
                      DateTime.tryParse(booking.session.sessionDate) ??
                      DateTime.now();

                  return UpcomingSessionCard(
                    name: booking.coach.name,
                    sport: booking.session.sportName,
                    date: _formatDateLabel(scheduledAt),
                    time: _formatTimeLabel(
                      scheduledAt,
                      booking.session.startTime,
                    ),
                    onTap: () => _openBookingDetails(booking),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Text(
          'Upcoming Sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onViewMore,
          child: const Text(
            'view more →',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class UpcomingSessionCard extends StatelessWidget {
  final String name;
  final String sport;
  final String date;
  final String time;
  final VoidCallback onTap;

  const UpcomingSessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sport,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(date),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    time,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback? onTap;

  const _StateCard({
    required this.message,
    required this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
