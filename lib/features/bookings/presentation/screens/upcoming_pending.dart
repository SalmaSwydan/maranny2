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

class _UpcomingScreenState extends State<UpcomingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample booking data
  late List<Map<String, dynamic>> _confirmedBookings;

  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'name': 'Mike Chen',
      'activity': 'Football',
      'date': 'Dec 17, 2025',
      'time': '4:00 AM - 5:00 AM',
      'location': 'Court 3',
      'price': '\$ 25/hr',
      'status': 'Pending',
    },
  ];

  late List<Map<String, dynamic>> _pendingRequestBookings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Load all confirmed bookings from persistent store (persists across navigation)
    _confirmedBookings = SharedBookingsManager.getConfirmedBookings();

    // Load pending requests from shared manager
    _pendingRequestBookings = SharedPendingRequestsManager.getAllPendingRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAcceptRequest(int index) {
    final request = _pendingRequestBookings[index];
    final status = request['status'] as String?;

    if (status == "You're busy") {
      // Show conflict message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Conflict'),
            content: const Text("You're busy at this time. You cannot accept this booking request."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Parse date string to extract date and time
    // Format: "Dec 18 at 3:00 PM" -> convert to booking format
    final dateStr = request['date'] as String;
    final timeStr = _extractTimeFromDate(dateStr);

    // Extract date part (before " at ")
    String parsedDate;
    if (dateStr.contains(' at ')) {
      final parts = dateStr.split(' at ');
      parsedDate = '${parts[0]}, 2025'; // "Dec 18, 2025"
    } else {
      parsedDate = dateStr;
    }

    // Add to confirmed bookings (local and persistent so it survives navigation)
    setState(() {
      final endTime = _addHourToTime(timeStr);
      final newBooking = {
        'name': request['name'],
        'activity': request['activity'],
        'date': parsedDate,
        'time': '$timeStr - $endTime',
        'location': 'Court TBD', // Default location
        'price': '\$ 25/hr',
        'status': 'Confirmed',
      };
      _confirmedBookings.add(newBooking);
      SharedBookingsManager.addAcceptedBooking(newBooking);

      // Remove from pending requests and shared manager
      final requestToRemove = _pendingRequestBookings[index];
      _pendingRequestBookings.removeAt(index);
      SharedPendingRequestsManager.removePendingRequest(
        requestToRemove['name'] as String,
        requestToRemove['date'] as String,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['name']} booking accepted successfully'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _extractTimeFromDate(String dateStr) {
    // Extract time from "Dec 18 at 3:00 PM" format
    if (dateStr.contains(' at ')) {
      final parts = dateStr.split(' at ');
      if (parts.length > 1) {
        return parts[1]; // Returns "3:00 PM"
      }
    }
    return 'TBD';
  }

  String _addHourToTime(String timeStr) {
    // Simple helper to add 1 hour to time string
    // Format: "3:00 PM" -> "4:00 PM"
    try {
      if (timeStr.contains('PM')) {
        final timePart = timeStr.replaceAll(' PM', '').trim();
        final parts = timePart.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 1;
          final minute = parts[1];
          final newHour = hour == 12 ? 1 : (hour + 1);
          return '$newHour:$minute PM';
        }
      } else if (timeStr.contains('AM')) {
        final timePart = timeStr.replaceAll(' AM', '').trim();
        final parts = timePart.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 1;
          final minute = parts[1];
          final newHour = hour == 12 ? 1 : (hour + 1);
          return '$newHour:$minute AM';
        }
      }
    } catch (e) {
      // If parsing fails, return a default end time
      return '4:00 PM';
    }
    return '4:00 PM';
  }

  void _handleDeclineRequest(int index) {
    final request = _pendingRequestBookings[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Decline Request'),
          content: Text('Are you sure you want to decline ${request['name']}\'s booking request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final requestToRemove = _pendingRequestBookings[index];
                setState(() {
                  _pendingRequestBookings.removeAt(index);
                  SharedPendingRequestsManager.removePendingRequest(
                    requestToRemove['name'] as String,
                    requestToRemove['date'] as String,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking request declined'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _handleCancelBooking(int index, bool isPending) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // ✅ NO bottomNavigationBar - handled by CoachMainLayout
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF6FD3F5), // light blue
                  Color(0xFF1F3A93), // deep blue
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
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
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Pending Requests'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Confirmed bookings
                      ..._confirmedBookings.asMap().entries.map((entry) {
                        final booking = entry.value;
                        return BookingCard(
                          name: booking['name'],
                          activity: booking['activity'],
                          date: booking['date'],
                          time: booking['time'],
                          location: booking['location'],
                          price: booking['price'],
                          status: booking['status'],
                          onCancel: () => _handleCancelBooking(entry.key, false),
                        );
                      }),
                      // Pending Confirmation section
                      if (_pendingBookings.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Pending Confirmation (${_pendingBookings.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ..._pendingBookings.asMap().entries.map((entry) {
                          final booking = entry.value;
                          return BookingCard(
                            name: booking['name'],
                            activity: booking['activity'],
                            date: booking['date'],
                            time: booking['time'],
                            location: booking['location'],
                            price: booking['price'],
                            status: booking['status'],
                            onCancel: () => _handleCancelBooking(entry.key, true),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Pending Requests Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ..._pendingRequestBookings.asMap().entries.map((entry) {
                        final request = entry.value;
                        return PendingRequestCard(
                          name: request['name'],
                          sport: request['activity'],
                          date: request['date'],
                          status: request['status'],
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