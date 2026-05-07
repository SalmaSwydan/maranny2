import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bookings_models.dart';

/// cardMode:
///   'upcoming'   — shows Cancel button  (default)
///   'past'       — shows Mark No-Show + Session Done buttons
enum BookingCardMode { upcoming, past }

class BookingCard extends StatelessWidget {
  final String name;
  final String activity;
  final String date;
  final String time;
  final String location;
  final String price;
  final String status;

  // ── Upcoming actions ──
  final VoidCallback? onCancel;

  // ── Past session actions ──
  final BookingCardMode mode;
  final String sessionStatus; // 'none' | 'attended' | 'no_show'
  final bool isClientRestricted;
  final int noShowCount;
  final VoidCallback? onNoShow;
  final VoidCallback? onAttended;

  const BookingCard({
    super.key,
    required this.name,
    required this.activity,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.status,
    this.onCancel,
    this.mode = BookingCardMode.upcoming,
    this.sessionStatus = 'none',
    this.isClientRestricted = false,
    this.noShowCount = 0,
    this.onNoShow,
    this.onAttended,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = normalizeBookingStatus(status);
    final bool isConfirmed =
        normalizedStatus == 'confirmed' || normalizedStatus == 'completed';
    final bool isCancelled = normalizedStatus == 'cancelled';
    final Color statusColor = isCancelled
        ? Colors.red
        : isConfirmed
        ? AppColors.confirmed
        : AppColors.pending;
    final Color statusBgColor = isCancelled
        ? Colors.red.shade50
        : isConfirmed
        ? AppColors.confirmedLight
        : AppColors.pendingLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Client restriction warning banner ──
          if (isClientRestricted)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Account Restricted — $noShowCount no-shows recorded.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Header: name + status badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge — or session outcome badge for past
              if (mode == BookingCardMode.past && sessionStatus != 'none')
                _outcomeBadge()
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Date ──
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Time + Location ──
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.borderGray),
          const SizedBox(height: 12),

          // ── Bottom row: price + action ──
          if (mode == BookingCardMode.upcoming)
            _upcomingActions()
          else
            _pastActions(),
        ],
      ),
    );
  }

  // ── Past session: outcome badge ────────────────────────────
  Widget _outcomeBadge() {
    final isNoShow = sessionStatus == 'no_show';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isNoShow ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNoShow ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNoShow ? Icons.person_off : Icons.check_circle,
            size: 13,
            color: isNoShow ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isNoShow ? 'No-Show' : 'Attended',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isNoShow ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ── Upcoming bottom row ────────────────────────────────────
  Widget _upcomingActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Colors.red,
          ),
        ),
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  // ── Past session bottom row ────────────────────────────────
  Widget _pastActions() {
    // Already marked — show price + locked label
    if (sessionStatus != 'none') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            sessionStatus == 'attended'
                ? 'Marked as Attended'
                : 'Marked as No-Show',
            style: TextStyle(
              fontSize: 12,
              color: sessionStatus == 'attended' ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // Not yet marked — show both action buttons
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Mark No-Show
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNoShow,
                icon: const Icon(
                  Icons.person_off_outlined,
                  size: 15,
                  color: Colors.red,
                ),
                label: const Text(
                  'No-Show',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Session Done
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAttended,
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 15,
                  color: Colors.white,
                ),
                label: const Text(
                  'Session Done',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
