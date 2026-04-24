import 'package:flutter/material.dart';
import '../../../../../core/network/token_storage.dart';
import '../widgets/SessionCard.dart';
import '../widgets/header.dart';
import '../widgets/pending_request_card.dart';
import '../widgets/review_card.dart';
import '../../../bookings/presentation/utils/shared_bookings_manager.dart';
import '../../../bookings/presentation/screens/upcoming_pending.dart';
import '../../../reviews/presentation/screens/all_reviews_screen.dart';
import '../../../bookings/presentation/utils/shared_pending_requests_manager.dart';
import '../../../../../core/widgets/app_side_menu.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

class CoachHomeScreen extends StatefulWidget {
  final VoidCallback onAuthRequired;

  const CoachHomeScreen({super.key, required this.onAuthRequired});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Map<String, dynamic>> _pendingRequests;
  late List<Map<String, dynamic>> _todaysSchedule;

  String _userName = 'Coach';

  @override
  void initState() {
    super.initState();
    _loadUserName();

    if (SharedBookingsManager.getConfirmedBookings().isEmpty) {
      SharedBookingsManager.addAcceptedBooking({
        'name': 'Ahmed Mohamed',
        'activity': 'Football',
        'date': 'Dec 17, 2025',
        'time': '10:00 AM - 11:00 AM',
        'location': 'Court 3',
        'price': '250 LE/hr',
        'status': 'Confirmed',
      });

      SharedBookingsManager.addAcceptedBooking({
        'name': 'Sarah Johnson',
        'activity': 'Football',
        'date': 'Dec 17, 2025',
        'time': '2:00 PM - 3:00 PM',
        'location': 'Court 1',
        'price': '250 LE/hr',
        'status': 'Confirmed',
      });

      SharedBookingsManager.addAcceptedBooking({
        'name': 'Mike Chen',
        'activity': 'Football',
        'date': 'Dec 17, 2025',
        'time': '4:00 PM - 5:00 PM',
        'location': 'Court 2',
        'price': '250 LE/hr',
        'status': 'Pending',
      });
    }

    _refresh();
  }

  Future<void> _loadUserName() async {
    final displayName = await TokenStorage.getDisplayName();

    if (!mounted) return;

    setState(() {
      _userName = displayName != null && displayName.trim().isNotEmpty
          ? displayName.trim()
          : 'Coach';
    });
  }

  void _refresh() {
    setState(() {
      _todaysSchedule = SharedBookingsManager.getConfirmedBookings();
      _pendingRequests = SharedPendingRequestsManager.getNextPendingRequests(2);
    });
  }

  String _extractTimeFromDate(String dateStr) {
    if (dateStr.contains(' at ')) {
      final parts = dateStr.split(' at ');
      if (parts.length > 1) return parts[1];
    }
    return 'TBD';
  }

  String _addHourToTime(String timeStr) {
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
    } catch (_) {
      return '4:00 PM';
    }

    return '4:00 PM';
  }

  void _handleAcceptRequest(int index) {
    final request = _pendingRequests[index];
    final status = request['status'] as String?;

    if (status == "You're busy") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Conflict'),
            content: const Text("You're busy at this time."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final dateStr = request['date'] as String;
    final timeStr = _extractTimeFromDate(dateStr);

    String parsedDate;
    if (dateStr.contains(' at ')) {
      final parts = dateStr.split(' at ');
      parsedDate = '${parts[0]}, 2025';
    } else {
      parsedDate = dateStr;
    }

    final endTime = _addHourToTime(timeStr);

    final newBooking = {
      'name': request['name'],
      'activity': request['activity'],
      'date': parsedDate,
      'time': '$timeStr - $endTime',
      'location': 'Court TBD',
      'price': '250 LE/hr',
      'status': 'Confirmed',
    };

    SharedBookingsManager.addAcceptedBooking(newBooking);
    SharedPendingRequestsManager.removePendingRequest(
      request['name'] as String,
      request['date'] as String,
    );

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['name']} booking accepted successfully.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleDeclineRequest(int index) {
    final request = _pendingRequests[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F3A93).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    color: Color(0xFF1F3A93),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Decline Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Decline ${request['name']}\'s booking request?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1F3A93)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1F3A93),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          final r = _pendingRequests[index];

                          SharedPendingRequestsManager.removePendingRequest(
                            r['name'] as String,
                            r['date'] as String,
                          );

                          _refresh();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking request declined'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3A93),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: AppSideMenu(
        userName: _userName,
        userType: 'coach',
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoachHomeHeader(
              userName: _userName,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            _SectionTitleWithViewAll(
              title: "Today's Schedule",
              onViewAll: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpcomingScreen()),
                );
                _refresh();
              },
            ),

            if (_todaysSchedule.isEmpty)
              _emptyCard('No sessions scheduled today')
            else
              ..._todaysSchedule.take(3).map(
                    (s) => SessionCard(
                  name: s['name'] ?? '',
                  sport: s['activity'] ?? '',
                  time: s['time'] ?? '',
                  location: s['location'] ?? '',
                  status: s['status'] ?? 'Confirmed',
                ),
              ),

            _SectionTitleWithViewAll(
              title: 'Pending Requests',
              onViewAll: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpcomingScreen(initialTabIndex: 1),
                  ),
                );
                _refresh();
              },
            ),

            if (_pendingRequests.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have no pending requests at the moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ..._pendingRequests.asMap().entries.map((entry) {
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

            _SectionTitleWithViewAll(
              title: 'Recent Reviews',
              onViewAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllReviewsScreen()),
              ),
            ),

            const ReviewCard(
              name: "Ahmed Yasser",
              review: "Excellent coaching! Really improved My skills",
              timestamp: "2 days ago",
              rating: 5,
            ),

            const ReviewCard(
              name: "Maria K.",
              review: "Very patient and professional.",
              timestamp: "2 days ago",
              rating: 5,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

class _SectionTitleWithViewAll extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionTitleWithViewAll({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All →',
              style: TextStyle(
                color: Color(0xFF1F3A93),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}