import 'package:flutter/material.dart';
import 'package:maranny_two/features/bookings/presentation/screens/rate_coach_screen.dart';
import '../../domain/models/coach_data_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/booking_session_model.dart';
import '../../presentation/screens/coach_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  final VoidCallback onMessageTap;
  // ✅ FIX: added callback for "Book Another Coach"
  final VoidCallback onBookAnotherCoach;

  const BookingsScreen({
    super.key,
    required this.onMessageTap,
    required this.onBookAnotherCoach,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool isUpcoming = true;

  late List<BookingSessionModel> sessions;

  @override
  void initState() {
    super.initState();

    final names = [
      'Sarah Ahmed',
      'Ahmed Mohamed',
      'Nancy Ali',
      'Ziad Marwan',
      'Fatima Hassan',
      'Omar Khaled',
      'Mariam Adel',
      'Youssef Nabil',
      'Nada Samir',
      'Kareem Tarek',
    ];

    final sports = ['Swimming 🏊‍♀️', 'Football ⚽', 'Yoga 🧘‍♀️', 'Padel 🎾'];

    sessions = List.generate(10, (i) {
      return BookingSessionModel(
        id: '$i',
        coachName: names[i],
        sport: sports[i % sports.length],
        location: 'Cairo, Egypt',
        date: DateTime.now().subtract(Duration(days: i * 3)),
        isPast: i >= 5,
        isReviewed: i == 7,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = sessions.where((s) => s.isPast != isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Column(
        children: [
          _tabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                return _sessionCard(filtered[index]);
              },
            ),
          ),
          if (isUpcoming)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _primaryButton(
                text: 'Book Another Coach',
                // ✅ FIX: wire up the callback
                onTap: widget.onBookAnotherCoach,
              ),
            ),
        ],
      ),
    );
  }

  /// ------------------ Tabs ------------------
  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _tabButton('Upcoming', isUpcoming, () {
            setState(() => isUpcoming = true);
          }),
          _tabButton('Past Sessions', !isUpcoming, () {
            setState(() => isUpcoming = false);
          }),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                color: active ? AppColors.primaryBlue : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              color: active ? AppColors.primaryBlue : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  /// ------------------ Session Card ------------------
  Widget _sessionCard(BookingSessionModel session) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.coachName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(session.sport, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '${session.date.day}/${session.date.month}/${session.date.year} • 2:00 PM',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionButton(
                  text: session.isPast ? 'Rate Coach' : 'Message Coach',
                  active: false,
                  onTap: () {
                    if (session.isPast) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RateSessionScreen(
                            onSubmitted: () {
                              setState(() => session.isReviewed = true);
                            },
                          ),
                        ),
                      );
                    } else {
                      widget.onMessageTap();
                    }
                  },
                ),
                const SizedBox(width: 12),
                session.isPast && session.isReviewed
                    ? Chip(
                  label: const Text('Reviewed'),
                  backgroundColor: Colors.green.shade100,
                )
                    : _actionButton(
                  text: 'Details',
                  active: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoachDetailsScreen(
                          session: session,
                          image: '',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------ Buttons ------------------
  Widget _actionButton({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          active ? AppColors.primaryBlue : AppColors.disabledGray,
          foregroundColor: active ? Colors.white : Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
