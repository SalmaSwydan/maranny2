import 'package:flutter/material.dart';
import 'package:maranny_two/features/bookings/presentation/screens/rate_coach_screen.dart';
import '../../domain/models/coach_data_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/booking_session_model.dart';
import '../../presentation/screens/coach_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  final VoidCallback onMessageTap;
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
        // ✅ upcoming sessions have FUTURE dates, past sessions have past dates
        date: i < 5
            ? DateTime.now().add(Duration(days: i * 3 + 1))
            : DateTime.now().subtract(Duration(days: (i - 4) * 3)),
        isPast: i >= 5,
        isReviewed: i == 7,
      );
    });
  }

  // ✅ True if session starts within the next 24 hours (lock window)
  bool _isWithin24Hours(DateTime sessionDate) {
    final diff = sessionDate.difference(DateTime.now());
    return diff.inHours < 24 && diff.inHours >= 0;
  }

  // ✅ Show reschedule request bottom sheet
  void _showRescheduleSheet(BookingSessionModel session) {
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Request Reschedule',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Session with ${session.coachName}',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF6FD3F5)
                              .withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFF1F3A93), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your reschedule request will be sent to the coach for approval. You will be notified once they respond.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1F3A93)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pick new date
                  const Text('Preferred New Date',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                        DateTime.now().add(const Duration(days: 1)),
                        firstDate:
                        DateTime.now().add(const Duration(days: 1)),
                        lastDate:
                        DateTime.now().add(const Duration(days: 60)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1F3A93),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => pickedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            pickedDate == null
                                ? 'Select a date'
                                : '${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: pickedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pick new time
                  const Text('Preferred New Time',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1F3A93),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => pickedTime = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            pickedTime == null
                                ? 'Select a time'
                                : pickedTime!.format(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: pickedTime == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (pickedDate != null && pickedTime != null)
                          ? () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reschedule request sent to ${session.coachName}!',
                            ),
                            backgroundColor: Colors.green,
                            duration:
                            const Duration(seconds: 3),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3A93),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Send Reschedule Request',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
    sessions.where((s) => s.isPast != isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
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
              itemBuilder: (_, index) =>
                  _sessionCard(filtered[index]),
            ),
          ),
          if (isUpcoming)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _primaryButton(
                text: 'Book Another Coach',
                onTap: widget.onBookAnotherCoach,
              ),
            ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────
  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _tabButton('Upcoming', isUpcoming,
                  () => setState(() => isUpcoming = true)),
          _tabButton('Past Sessions', !isUpcoming,
                  () => setState(() => isUpcoming = false)),
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
                color: active
                    ? AppColors.primaryBlue
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              color: active
                  ? AppColors.primaryBlue
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // ── Session Card ──────────────────────────────────────────
  Widget _sessionCard(BookingSessionModel session) {
    final locked =
        !session.isPast && _isWithin24Hours(session.date);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach name
            Text(session.coachName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            // Sport
            Text(session.sport,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),

            // Date
            Text(
              '${session.date.day}/${session.date.month}/${session.date.year} • 2:00 PM',
            ),
            const SizedBox(height: 12),

            // ── Row 1: Message Coach + Details ──
            Row(
              children: [
                _actionButton(
                  text: session.isPast
                      ? 'Rate Coach'
                      : 'Message Coach',
                  active: false,
                  onTap: () {
                    if (session.isPast) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RateSessionScreen(
                            onSubmitted: () => setState(
                                    () => session.isReviewed = true),
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
                    ? Expanded(
                  child: Chip(
                    label: const Text('Reviewed'),
                    backgroundColor:
                    Colors.green.shade100,
                  ),
                )
                    : _actionButton(
                  text: 'Details',
                  active: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoachDetailsScreen(
                        session: session,
                        image: '',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Row 2: Request Reschedule (upcoming only) ──
            if (!session.isPast) ...[
              const SizedBox(height: 10),

              // 24hr lock warning
              if (locked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Reschedule is locked — session starts within 24 hours.',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

              // Reschedule button — disabled when locked
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                  locked ? null : () => _showRescheduleSheet(session),
                  icon: Icon(
                    Icons.schedule,
                    size: 16,
                    color: locked
                        ? Colors.grey
                        : const Color(0xFF1F3A93),
                  ),
                  label: Text(
                    'Request Reschedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: locked
                          ? Colors.grey
                          : const Color(0xFF1F3A93),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: locked
                          ? Colors.grey.shade300
                          : const Color(0xFF1F3A93),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                    disabledForegroundColor:
                    Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Reusable Buttons ──────────────────────────────────────
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _primaryButton(
      {required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Text(text,
          style: const TextStyle(color: Colors.white)),
    );
  }
}