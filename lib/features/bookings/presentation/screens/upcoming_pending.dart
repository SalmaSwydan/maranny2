import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/booking_card.dart';
import '../../../home/presentation/widgets/pending_request_card.dart';
import '../utils/shared_bookings_manager.dart';
import '../utils/shared_pending_requests_manager.dart';
import '../utils/no_show_manager.dart';

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
  late List<Map<String, dynamic>> _pendingRequestBookings;

  // ── Past sessions (mock — sessions whose time has already passed) ──
  final List<Map<String, dynamic>> _pastSessions = [
    {
      'name': 'Ahmed Mohamed',
      'activity': 'Football',
      'date': 'Dec 10, 2025',
      'time': '10:00 AM - 11:00 AM',
      'location': 'Court 3',
      'price': '250 LE/hr',
      'status': 'Confirmed',
    },
    {
      'name': 'Sara Khalil',
      'activity': 'Swimming',
      'date': 'Dec 8, 2025',
      'time': '9:00 AM - 10:00 AM',
      'location': 'Pool 1',
      'price': '200 LE/hr',
      'status': 'Confirmed',
    },
    {
      'name': 'Ahmed Mohamed', // same client — already has 1 no-show above
      'activity': 'Football',
      'date': 'Dec 5, 2025',
      'time': '2:00 PM - 3:00 PM',
      'location': 'Court 1',
      'price': '250 LE/hr',
      'status': 'Confirmed',
    },
    {
      'name': 'Omar Nabil',
      'activity': 'Yoga',
      'date': 'Dec 3, 2025',
      'time': '7:00 AM - 8:00 AM',
      'location': 'Studio 2',
      'price': '150 LE/hr',
      'status': 'Confirmed',
    },
  ];

  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'name': 'Mike Chen',
      'activity': 'Football',
      'date': 'Dec 17, 2025',
      'time': '4:00 AM - 5:00 AM',
      'location': 'Court 3',
      'price': '250 LE/hr',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    // ✅ 3 tabs: Upcoming | Pending Requests | Past Sessions
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _confirmedBookings = SharedBookingsManager.getConfirmedBookings();
    _pendingRequestBookings =
        SharedPendingRequestsManager.getAllPendingRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Session key for NoShowManager ─────────────────────────
  String _sessionKey(Map<String, dynamic> s) =>
      '${s['name']}|${s['date']}|${s['time']}';

  // ── Mark No-Show ──────────────────────────────────────────
  void _markNoShow(Map<String, dynamic> session) {
    final clientName = session['name'] as String;
    final prevCount = NoShowManager.getCount(clientName);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_off_outlined,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Mark as No-Show',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '$clientName did not attend this session?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Restriction warning preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  prevCount + 1 >=
                      NoShowManager.restrictionThreshold
                      ? '⚠️ This will flag $clientName\'s account as restricted (${prevCount + 1} no-shows).'
                      : 'No-show count for $clientName will become ${prevCount + 1}. Account is restricted at ${NoShowManager.restrictionThreshold}.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF1F3A93)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
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
                      setState(() {
                        NoShowManager.setSessionNoShow(
                          session['name'],
                          session['date'],
                          session['time'],
                        );
                      });
                      final newCount =
                      NoShowManager.getCount(clientName);
                      final restricted =
                      NoShowManager.isRestricted(clientName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            restricted
                                ? '⚠️ $clientName marked as no-show. Account is now restricted ($newCount no-shows).'
                                : '$clientName marked as no-show ($newCount total).',
                          ),
                          backgroundColor: restricted
                              ? Colors.red
                              : Colors.orange,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Mark No-Show',
                        style: TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mark Attended ─────────────────────────────────────────
  void _markAttended(Map<String, dynamic> session) {
    setState(() {
      NoShowManager.setSessionAttended(
        session['name'],
        session['date'],
        session['time'],
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${session['name']} marked as attended. ✓'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Accept booking request ─────────────────────────────────
  void _handleAcceptRequest(int index) {
    final request = _pendingRequestBookings[index];
    if (request['status'] == "You're busy") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Conflict'),
          content: const Text("You're busy at this time."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      return;
    }
    final dateStr = request['date'] as String;
    String parsedDate = dateStr.contains(' at ')
        ? '${dateStr.split(' at ')[0]}, 2025'
        : dateStr;
    final timeStr = dateStr.contains(' at ')
        ? dateStr.split(' at ')[1]
        : 'TBD';
    final newBooking = {
      'name': request['name'],
      'activity': request['activity'],
      'date': parsedDate,
      'time': timeStr,
      'location': 'Court TBD',
      'price': '250 LE/hr',
      'status': 'Confirmed',
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
      SnackBar(
          content:
          Text('${request['name']} booking accepted')),
    );
  }

  // ── Decline booking request ────────────────────────────────
  void _handleDeclineRequest(int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: const Color(0xFF1F3A93)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_off_outlined,
                    color: Color(0xFF1F3A93), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Decline Request',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Decline ${_pendingRequestBookings[index]['name']}\'s booking request?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF1F3A93)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
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
                        SharedPendingRequestsManager
                            .removePendingRequest(
                            r['name'] as String,
                            r['date'] as String);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF1F3A93),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Decline',
                        style: TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cancel booking ─────────────────────────────────────────
  void _handleCancelBooking(int index, bool isPending) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle),
                child: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Cancel Booking',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to cancel this booking?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF1F3A93)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
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
                          final removed =
                          _confirmedBookings[index];
                          _confirmedBookings.removeAt(index);
                          SharedBookingsManager
                              .removeConfirmedBooking(removed);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Booking cancelled successfully'),
                            duration: Duration(seconds: 2)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Yes, Cancel',
                        style: TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
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
          // ── Header ──
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
                padding:
                const EdgeInsets.fromLTRB(4, 8, 20, 16),
                child: Row(children: [
                  if (canPop)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    )
                  else
                    const SizedBox(width: 20),
                  const Text('My Bookings',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white)),
                ]),
              ),
            ),
          ),

          // ── Tab bar (3 tabs) ──
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Pending'),
                Tab(text: 'Past Sessions'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Upcoming ──────────────────────────
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ..._confirmedBookings
                          .asMap()
                          .entries
                          .map((entry) {
                        final b = entry.value;
                        return BookingCard(
                          name: b['name'],
                          activity: b['activity'],
                          date: b['date'],
                          time: b['time'],
                          location: b['location'],
                          price: b['price'],
                          status: b['status'],
                          onCancel: () =>
                              _handleCancelBooking(
                                  entry.key, false),
                        );
                      }),
                      if (_pendingBookings.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16, 16, 16, 8),
                          child: Text(
                            'Pending Confirmation (${_pendingBookings.length})',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        ..._pendingBookings
                            .asMap()
                            .entries
                            .map((entry) {
                          final b = entry.value;
                          return BookingCard(
                            name: b['name'],
                            activity: b['activity'],
                            date: b['date'],
                            time: b['time'],
                            location: b['location'],
                            price: b['price'],
                            status: b['status'],
                            onCancel: () =>
                                _handleCancelBooking(
                                    entry.key, true),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Tab 2: Pending Requests ──────────────────
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      if (_pendingRequestBookings.isEmpty)
                        _emptyState(
                          icon: Icons.check_circle_outline,
                          message: 'No pending requests',
                          sub:
                          'All requests have been handled.',
                        ),
                      ..._pendingRequestBookings
                          .asMap()
                          .entries
                          .map((entry) {
                        final r = entry.value;
                        return PendingRequestCard(
                          name: r['name'],
                          sport: r['activity'],
                          date: r['date'],
                          status: r['status'],
                          onAccept: () =>
                              _handleAcceptRequest(entry.key),
                          onDecline: () =>
                              _handleDeclineRequest(entry.key),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Tab 3: Past Sessions ─────────────────────
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Restricted clients summary banner
                      ..._buildRestrictionSummary(),

                      if (_pastSessions.isEmpty)
                        _emptyState(
                          icon: Icons.history,
                          message: 'No past sessions yet',
                          sub:
                          'Completed sessions will appear here.',
                        ),

                      ..._pastSessions.map((session) {
                        final clientName =
                        session['name'] as String;
                        final status =
                        NoShowManager.getSessionStatus(
                          clientName,
                          session['date'],
                          session['time'],
                        );
                        final restricted = NoShowManager
                            .isRestricted(clientName);
                        final count =
                        NoShowManager.getCount(clientName);

                        return BookingCard(
                          name: clientName,
                          activity: session['activity'],
                          date: session['date'],
                          time: session['time'],
                          location: session['location'],
                          price: session['price'],
                          status: session['status'],
                          mode: BookingCardMode.past,
                          sessionStatus: status,
                          isClientRestricted: restricted,
                          noShowCount: count,
                          onNoShow: status == 'none'
                              ? () => _markNoShow(session)
                              : null,
                          onAttended: status == 'none'
                              ? () => _markAttended(session)
                              : null,
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

  // ── Restricted clients summary banner ─────────────────────
  List<Widget> _buildRestrictionSummary() {
    final restricted = <String>{};
    for (final s in _pastSessions) {
      final name = s['name'] as String;
      if (NoShowManager.isRestricted(name)) {
        restricted.add(name);
      }
    }
    if (restricted.isEmpty) return [];

    return [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Restricted Clients',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14),
              ),
            ]),
            const SizedBox(height: 6),
            ...restricted.map((name) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.circle,
                    size: 6, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '$name — ${NoShowManager.getCount(name)} no-shows',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.red),
                ),
              ]),
            )),
            const SizedBox(height: 8),
            const Text(
              'These clients have been flagged for repeated no-shows. You can report them via the side menu.',
              style:
              TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Empty state widget ─────────────────────────────────────
  Widget _emptyState({
    required IconData icon,
    required String message,
    required String sub,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 32),
      child: Center(
        child: Column(children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400)),
        ]),
      ),
    );
  }
}