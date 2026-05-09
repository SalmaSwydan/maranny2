import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../widgets/booking_card.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
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
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(
                          bookings: upcoming,
                          emptyMessage: 'No upcoming bookings yet',
                          isPending: false,
                        ),
                        _buildBookingsList(
                          bookings: pending,
                          emptyMessage: 'No pending requests',
                          isPending: true,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final canPop = Navigator.of(context).canPop();

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
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 16),
          child: Row(
            children: [
              if (canPop)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                const SizedBox(width: 20),
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Pending'),
        ],
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
        children: [
          const SizedBox(height: 180),
          Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final session = booking.session;

        if (isPending) {
          return _PendingApiCard(
            name: _clientName(booking),
            activity: session.sportName,
            date: _formatDate(session.sessionDate),
            time:
                '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
            onAccept: () => _approveBooking(booking),
            onDecline: () => _confirmDecline(booking),
          );
        }

        return BookingCard(
          name: _clientName(booking),
          activity: session.sportName,
          date: _formatDate(session.sessionDate),
          time:
              '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
          location: session.location,
          price: _price(booking),
          status: booking.status,
          mode: _isPastSession(booking)
              ? BookingCardMode.past
              : BookingCardMode.upcoming,
          onCancel: () => _confirmCancel(booking),
        );
      },
    );
  }
}

class _PendingApiCard extends StatelessWidget {
  final String name;
  final String activity;
  final String date;
  final String time;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingApiCard({
    required this.name,
    required this.activity,
    required this.date,
    required this.time,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pendingLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: AppColors.pending,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 12),
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
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.close, color: Colors.black, size: 18),
                  label: const Text(
                    'Decline',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.disabledGray,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
