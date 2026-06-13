import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/data/models/bookings_models.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../bookings/presentation/screens/session_info_screen.dart';

class UpcomingSessionsSection extends StatefulWidget {
  final VoidCallback? onViewMore;

  const UpcomingSessionsSection({super.key, this.onViewMore});

  @override
  State<UpcomingSessionsSection> createState() =>
      _UpcomingSessionsSectionState();
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

    final upcoming =
        bookings.where((booking) {
          final normalizedStatus = booking.normalizedStatus;
          final isUpcomingStatus =
              normalizedStatus == 'approved' ||
              normalizedStatus == 'confirmed' ||
              normalizedStatus == 'completed';
          final scheduledAt = booking.scheduledDateTime;
          return isUpcomingStatus &&
              scheduledAt != null &&
              !scheduledAt.isBefore(now);
        }).toList()..sort((a, b) {
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionInfoScreen(booking: bookingDetails),
      ),
    );

    if (!mounted) return;
    setState(() {
      _bookingsFuture = _loadUpcomingBookings();
    });
  }

  String _formatDateLabel(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
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
        const Text(
          'UP NEXT',
          style: TextStyle(
            color: Color(0xFF9AA9C6),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
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

              final booking = bookings.first;
              final scheduledAt =
                  booking.scheduledDateTime ??
                  DateTime.tryParse(booking.session.sessionDate) ??
                  DateTime.now();

              return UpcomingSessionCard(
                name: booking.coach.name,
                sport: booking.session.sportName,
                location: booking.session.location,
                date: _formatDateLabel(scheduledAt),
                time: _formatTimeLabel(scheduledAt, booking.session.startTime),
                onTap: () => _openBookingDetails(booking),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UpcomingSessionCard extends StatelessWidget {
  final String name;
  final String sport;
  final String location;
  final String date;
  final String time;
  final VoidCallback onTap;

  const UpcomingSessionCard({
    super.key,
    required this.name,
    required this.sport,
    required this.location,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: AppColors.deepBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$date  -  $time'.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$sport with $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    location.trim().isEmpty ? 'Coach location' : location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF38607A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.deepBlue,
              size: 24,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
