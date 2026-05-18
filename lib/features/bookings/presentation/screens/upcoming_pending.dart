import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../utils/bookings_refresh_notifier.dart';

class UpcomingScreen extends StatefulWidget {
  final int initialTabIndex;

  const UpcomingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen>
    with SingleTickerProviderStateMixin {
  final BookingsRepository _repo = BookingsRepository();

  late TabController _tabController;

  bool _isLoading = true;
  String? _error;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex > 1 ? 0 : widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    BookingsRefreshNotifier.changes.addListener(_handleRefreshSignal);
    _loadBookings();
  }

  @override
  void dispose() {
    BookingsRefreshNotifier.changes.removeListener(_handleRefreshSignal);
    _tabController.dispose();
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
      final data = await _repo.getCoachBookings();

      if (!mounted) return;

      _logCoachBookingBuckets(data);

      setState(() {
        _bookings = data;
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

  bool _isPast(BookingModel booking) {
    final scheduledAt = booking.scheduledDateTime;
    if (scheduledAt == null) {
      return false;
    }
    return scheduledAt.isBefore(DateTime.now());
  }

  bool _isPending(BookingModel booking) =>
      isPendingBookingStatus(booking.status);

  bool _isConfirmed(BookingModel booking) =>
      isConfirmedBookingStatus(booking.status);

  bool _isUpcoming(BookingModel booking) => _isConfirmed(booking);

  bool _isPastSession(BookingModel booking) =>
      _isPast(booking) && isCompletedBookingStatus(booking.status);

  void _logCoachBookingBuckets(List<BookingModel> bookings) {
    developer.log(
      'Coach bookings categorized -> '
      'pending=${bookings.where(_isPending).map((b) => _bookingLogMap(b)).toList(growable: false)} '
      'upcoming=${bookings.where(_isUpcoming).map((b) => _bookingLogMap(b)).toList(growable: false)} '
      'past=${bookings.where(_isPastSession).map((b) => _bookingLogMap(b)).toList(growable: false)}',
      name: 'UpcomingScreen',
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

  String _clientName(BookingModel booking) {
    final clientName = booking.client?.name;
    if (clientName != null && clientName.isNotEmpty) {
      return clientName;
    }
    return 'Client';
  }

  String _price(BookingModel booking) {
    final price = booking.session.price;
    if (price == null || price <= 0) {
      return 'Price not set';
    }
    if (price == price.roundToDouble()) {
      return '${price.toInt()} LE';
    }
    return '${price.toStringAsFixed(2)} LE';
  }

  Future<void> _approveBooking(BookingModel booking) async {
    try {
      await _repo.approveBooking(booking.bookingID);
      BookingsRefreshNotifier.notifyUpdated();
      await _loadBookings();

      if (!mounted) return;
      _tabController.animateTo(0);
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
      await _repo.declineBooking(booking.bookingID);
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

  Future<void> _cancelBooking(BookingModel booking) async {
    try {
      final response = await _repo.cancelSessionWithRefund(
        booking.session.sessionID,
        reason: 'Cancelled by coach',
      );
      BookingsRefreshNotifier.notifyUpdated();
      await _loadBookings();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to cancel booking')));
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

  void _confirmCancel(BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking);
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _bookings.where(_isUpcoming).toList();

    final pending = _bookings.where(_isPending).toList();
    final selectedBookings = _tabController.index == 0 ? upcoming : pending;
    final isPendingTab = _tabController.index == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Column(
        children: [
          _buildHeader(
            upcomingCount: upcoming.length,
            pendingCount: pending.length,
          ),
          _buildTabs(
            upcomingCount: upcoming.length,
            pendingCount: pending.length,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: TextButton(
                      onPressed: _loadBookings,
                      child: Text(_error!),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBookings,
                    child: _buildBookingsList(
                      bookings: selectedBookings,
                      emptyMessage: isPendingTab
                          ? 'No pending requests'
                          : 'No upcoming bookings yet',
                      isPending: isPendingTab,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required int upcomingCount, required int pendingCount}) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (canPop)
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  )
                else
                  const _CircleIconButton(icon: Icons.calendar_month_rounded),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: _loadBookings,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'COACH SCHEDULE',
              style: TextStyle(
                color: Color(0xFF9AA9C6),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bookings.',
              style: TextStyle(
                color: AppColors.deepBlue,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'Upcoming',
                    value: upcomingCount.toString(),
                    icon: Icons.event_available_rounded,
                    color: AppColors.lightBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryTile(
                    label: 'Pending',
                    value: pendingCount.toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFFFE8B3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs({required int upcomingCount, required int pendingCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFE7EEF9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            _BookingTabButton(
              label: 'Upcoming',
              count: upcomingCount,
              selected: _tabController.index == 0,
              onTap: () => _tabController.animateTo(0),
            ),
            _BookingTabButton(
              label: 'Pending',
              count: pendingCount,
              selected: _tabController.index == 1,
              onTap: () => _tabController.animateTo(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList({
    required List<BookingModel> bookings,
    required String emptyMessage,
    required bool isPending,
  }) {
    if (bookings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 24),
        children: [
          _ModernEmptyState(
            title: emptyMessage,
            message: isPending
                ? 'New client requests will appear here for approval.'
                : 'Approved sessions will appear here once clients book you.',
            icon: isPending
                ? Icons.mark_email_unread_outlined
                : Icons.event_busy_rounded,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final session = booking.session;

        if (isPending) {
          return _CoachBookingCard(
            name: _clientName(booking),
            activity: session.sportName,
            date: _formatDate(session.sessionDate),
            time:
                '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
            location: session.location,
            price: _price(booking),
            statusLabel: 'Pending',
            statusColor: const Color(0xFFE9A500),
            statusBackground: const Color(0xFFFFF4D6),
            onAccept: () => _approveBooking(booking),
            onDecline: () => _confirmDecline(booking),
          );
        }

        return _CoachBookingCard(
          name: _clientName(booking),
          activity: session.sportName,
          date: _formatDate(session.sessionDate),
          time:
              '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
          location: session.location,
          price: _price(booking),
          statusLabel: 'Confirmed',
          statusColor: const Color(0xFF1FA463),
          statusBackground: const Color(0xFFE0F7EA),
          onCancel: () => _confirmCancel(booking),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD7E0F2)),
        ),
        child: Icon(icon, color: AppColors.deepBlue, size: 20),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E0F2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.deepBlue, size: 19),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6C7897),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _BookingTabButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.deepBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '$label - $count',
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF647391),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _ModernEmptyState({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FB),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachBookingCard extends StatelessWidget {
  final String name;
  final String activity;
  final String date;
  final String time;
  final String location;
  final String price;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  const _CoachBookingCard({
    required this.name,
    required this.activity,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E0F2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.07),
            blurRadius: 18,
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
                radius: 24,
                backgroundColor: const Color(0xFFEAF0FB),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7897),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE1E7F2)),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.calendar_today_rounded, label: date),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.access_time_rounded, label: time),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: location.trim().isEmpty ? 'Location not set' : location,
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.payments_outlined, label: price),
          const SizedBox(height: 14),
          if (onAccept != null && onDecline != null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD94A4A),
                      side: const BorderSide(color: Color(0xFFFFC9C9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),
              ],
            )
          else if (onCancel != null)
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD94A4A),
                side: const BorderSide(color: Color(0xFFFFC9C9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 46),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF33415F),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
