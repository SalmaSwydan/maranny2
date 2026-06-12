import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cairo_time.dart';
import '../../data/models/bookings_models.dart';

class SessionInfoScreen extends StatelessWidget {
  const SessionInfoScreen({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final session = booking.session;
    final scheduledAt = booking.scheduledDateTime;
    final price = _priceText(booking);
    final status = _statusLabel(booking);
    final isFinished = _isFinished(booking);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Session info.',
                    style: TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFD7E0F2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepBlue.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFEAF0FB),
                        child: Text(
                          _initial(booking.coach.name),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.coach.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              session.sportName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6C7897),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(label: status, finished: isFinished),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFE1E7F2)),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'When',
                    value: scheduledAt == null
                        ? _formatDate(session.sessionDate)
                        : _formatDateTime(scheduledAt),
                  ),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Time',
                    value: _timeRange(session),
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: _clean(
                      session.location,
                      fallback: 'Location not set',
                    ),
                  ),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Cost',
                    value: price,
                  ),
                  _InfoRow(
                    icon: Icons.flag_circle_outlined,
                    label: 'Status',
                    value: isFinished ? 'Finished' : status,
                  ),
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Booking ID',
                    value: '#${booking.bookingID}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFBFEAFF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.deepBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isFinished
                          ? 'This session is already finished. You can review it from your past bookings if it has not been reviewed yet.'
                          : 'This screen shows the real booking data saved for this session, including the selected time, location, price, and current status.',
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFinished(BookingModel booking) {
    if (isCompletedBookingStatus(booking.status)) return true;
    final scheduledAt = booking.scheduledDateTime;
    return scheduledAt != null && scheduledAt.isBefore(CairoTime.now());
  }

  String _statusLabel(BookingModel booking) {
    final normalized = booking.normalizedStatus;
    if (normalized == 'confirmed') return 'Confirmed';
    if (normalized == 'completed') return 'Completed';
    if (normalized == 'pending') return 'Pending';
    if (normalized == 'cancelled') return 'Cancelled';
    return booking.status.trim().isEmpty ? 'Pending' : booking.status;
  }

  String _priceText(BookingModel booking) {
    final price = booking.session.price ?? booking.amount;
    if (price == null || price <= 0) return 'Price not set';
    final clean = price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
    return '$clean LE';
  }

  String _timeRange(SessionModel session) {
    final start = _formatTime(session.startTime);
    final end = _formatTime(session.endTime);
    if (start.isEmpty && end.isEmpty) return 'Time not set';
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  String _formatDate(String raw) {
    final parsed = CairoTime.parse(raw);
    if (parsed == null) return raw.trim().isEmpty ? 'Date not set' : raw;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  String _formatDateTime(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]} ${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
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

  String _clean(String value, {required String fallback}) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'C' : trimmed[0].toUpperCase();
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD7E0F2)),
        ),
        child: Icon(icon, color: AppColors.deepBlue, size: 18),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.finished});

  final String label;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    final color = finished ? const Color(0xFF6C7897) : AppColors.deepBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: finished ? const Color(0xFFEAF0FB) : const Color(0xFFE0F7EA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6C7897),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
