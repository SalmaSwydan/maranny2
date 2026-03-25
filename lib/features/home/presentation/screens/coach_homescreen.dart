import 'package:flutter/material.dart';

import '../widgets/SectionTitle.dart';
import '../widgets/SessionCard.dart';
import '../widgets/header.dart';
import '../widgets/pending_request_card.dart';
import '../widgets/review_card.dart';
import '../../../bookings/presentation/utils/shared_bookings_manager.dart';
import '../../../bookings/presentation/utils/shared_pending_requests_manager.dart';

class CoachHomeScreen extends StatefulWidget {
  final VoidCallback onAuthRequired;

  const CoachHomeScreen({
    super.key,
    required this.onAuthRequired,
  });

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  // Pending requests list - initialized from shared manager
  late List<Map<String, dynamic>> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _refreshPendingRequests();
  }

  void _refreshPendingRequests() {
    // Always show the first 2 pending requests from shared manager
    setState(() {
      _pendingRequests = SharedPendingRequestsManager.getNextPendingRequests(2);
    });
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

  void _handleAcceptRequest(int index) {
    final request = _pendingRequests[index];
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

    // Create booking object and add to shared manager
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

    // Add to shared bookings manager
    SharedBookingsManager.addAcceptedBooking(newBooking);

    // Remove from shared manager
    SharedPendingRequestsManager.removePendingRequest(
      request['name'] as String,
      request['date'] as String,
    );

    // Refresh the list to show next pending requests
    _refreshPendingRequests();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['name']} booking accepted successfully. Check the Upcoming tab in Bookings.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleDeclineRequest(int index) {
    final request = _pendingRequests[index];

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
                final requestToRemove = _pendingRequests[index];
                // Remove from shared manager
                SharedPendingRequestsManager.removePendingRequest(
                  requestToRemove['name'] as String,
                  requestToRemove['date'] as String,
                );

                // Refresh the list to show next pending requests
                _refreshPendingRequests();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // ✅ NO bottomNavigationBar - handled by CoachMainLayout
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient, avatar, welcome message, and stat cards
              const CoachHomeHeader(),

              // Today's Schedule Section
              const SectionTitle(title: "Today's Schedule"),
              const SessionCard(
                name: "Ahmed Mohamed",
                sport: "Football",
                time: "10:00 AM - 11:00 AM",
                location: "Court 3",
                status: "Confirmed",
              ),
              const SessionCard(
                name: "Sarah Johnson",
                sport: "Football",
                time: "2:00 AM - 3:00 AM",
                location: "Court 1",
                status: "Confirmed",
              ),
              const SessionCard(
                name: "Mike Chen",
                sport: "Football",
                time: "4:00 AM - 5:00 AM",
                location: "Court 2",
                status: "Pending",
              ),

              // Pending Requests Section
              const SectionTitle(title: "Pending Requests"),
              if (_pendingRequests.isEmpty)
              // Empty state when no pending requests
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                          fontFamily: 'Poppins',
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have no pending requests at the moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                        ),
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

              // Recent Reviews Section
              const SectionTitle(title: "Recent Reviews"),
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
      ),
    );
  }
}