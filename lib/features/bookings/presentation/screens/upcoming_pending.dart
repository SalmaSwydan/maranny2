import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/booking_card.dart';
import '../../../home/presentation/widgets/pending_request_card.dart';
import '../utils/shared_bookings_manager.dart';
import '../utils/shared_pending_requests_manager.dart';

class UpcomingScreen extends StatefulWidget {
  final int initialTabIndex;
  const UpcomingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _confirmedBookings;

  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'name': 'Mike Chen', 'activity': 'Football',
      'date': 'Dec 17, 2025', 'time': '4:00 AM - 5:00 AM',
      'location': 'Court 3', 'price': '250 LE/hr', 'status': 'Pending',
    },
  ];

  late List<Map<String, dynamic>> _pendingRequestBookings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _confirmedBookings = SharedBookingsManager.getConfirmedBookings();
    _pendingRequestBookings =
        SharedPendingRequestsManager.getAllPendingRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAcceptRequest(int index) {
    final request = _pendingRequestBookings[index];
    if (request['status'] == "You're busy") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Conflict'),
          content: const Text("You're busy at this time."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    final dateStr = request['date'] as String;
    String parsedDate = dateStr.contains(' at ')
        ? '${dateStr.split(' at ')[0]}, 2025'
        : dateStr;
    final timeStr = dateStr.contains(' at ') ? dateStr.split(' at ')[1] : 'TBD';
    final newBooking = {
      'name': request['name'], 'activity': request['activity'],
      'date': parsedDate, 'time': timeStr,
      'location': 'Court TBD', 'price': '250 LE/hr', 'status': 'Confirmed',
    };
    setState(() {
      _confirmedBookings.add(newBooking);
      SharedBookingsManager.addAcceptedBooking(newBooking);
      final r = _pendingRequestBookings[index];
      _pendingRequestBookings.removeAt(index);
      SharedPendingRequestsManager.removePendingRequest(
          r['name'] as String, r['date'] as String);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${request['name']} booking accepted')),
    );
  }

  void _handleDeclineRequest(int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: const Color(0xFF1F3A93).withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_off_outlined,
                    color: Color(0xFF1F3A93), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Decline Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Decline ${_pendingRequestBookings[index]['name']}\'s booking request?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F3A93)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: Color(0xFF1F3A93),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final r = _pendingRequestBookings[index];
                        setState(() {
                          _pendingRequestBookings.removeAt(index);
                          SharedPendingRequestsManager.removePendingRequest(
                              r['name'] as String, r['date'] as String);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3A93),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Decline',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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

  void _handleCancelBooking(int index, bool isPending) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Cancel Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to cancel this booking?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F3A93)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('No',
                          style: TextStyle(
                              color: Color(0xFF1F3A93),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isPending) {
                            _pendingBookings.removeAt(index);
                          } else {
                            final removed = _confirmedBookings[index];
                            _confirmedBookings.removeAt(index);
                            SharedBookingsManager.removeConfirmedBooking(removed);
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Booking cancelled successfully'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Yes, Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ✅ Header with back button when pushed as route
          Container(
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
                    // ✅ Back button shown when pushed as route
                    if (canPop)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      )
                    else
                      const SizedBox(width: 20),
                    const Text('My Bookings',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins', color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Pending Requests')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ..._confirmedBookings.asMap().entries.map((entry) {
                        final b = entry.value;
                        return BookingCard(
                          name: b['name'], activity: b['activity'],
                          date: b['date'], time: b['time'],
                          location: b['location'], price: b['price'],
                          status: b['status'],
                          onCancel: () => _handleCancelBooking(entry.key, false),
                        );
                      }),
                      if (_pendingBookings.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Pending Confirmation (${_pendingBookings.length})',
                              style: const TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        ),
                        ..._pendingBookings.asMap().entries.map((entry) {
                          final b = entry.value;
                          return BookingCard(
                            name: b['name'], activity: b['activity'],
                            date: b['date'], time: b['time'],
                            location: b['location'], price: b['price'],
                            status: b['status'],
                            onCancel: () => _handleCancelBooking(entry.key, true),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Pending Requests tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ..._pendingRequestBookings.asMap().entries.map((entry) {
                        final r = entry.value;
                        return PendingRequestCard(
                          name: r['name'], sport: r['activity'],
                          date: r['date'], status: r['status'],
                          onAccept: () => _handleAcceptRequest(entry.key),
                          onDecline: () => _handleDeclineRequest(entry.key),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
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