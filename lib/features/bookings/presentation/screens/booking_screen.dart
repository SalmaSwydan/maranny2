import 'package:flutter/material.dart';
import 'package:maranny_two/features/messages/presentation/screens/chat_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../domain/models/booking_session_model.dart';
import '../../presentation/screens/coach_details_screen.dart';
import 'rate_coach_screen.dart';

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
  final BookingsRepository _repo = BookingsRepository();

  bool isUpcoming = true;
  bool _isLoading = true;
  String? _error;

  List<BookingModel> _bookings = [];
  final Map<int, String?> _activeButton = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getMyBookings();

      if (!mounted) return;

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
    try {
      final date = DateTime.parse(booking.session.sessionDate);
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

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

  int _coachUserId(BookingModel booking) {
    return booking.coach.coachID;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _bookings.where((b) {
      final past = _isPast(b);
      return isUpcoming ? !past : past;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          _tabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBookings,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ListView(
                children: [
                  const SizedBox(height: 220),
                  Center(
                    child: TextButton(
                      onPressed: _loadBookings,
                      child: Text(_error!),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                isUpcoming ? filtered.length + 1 : filtered.length,
                itemBuilder: (_, index) {
                  if (isUpcoming && index == filtered.length) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(top: 8, bottom: 8),
                      child: _primaryButton(
                        text: 'Book Another Coach',
                        onTap: widget.onBookAnotherCoach,
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return _emptyCard(
                      isUpcoming
                          ? 'No upcoming bookings yet'
                          : 'No past sessions yet',
                    );
                  }

                  return _bookingCard(filtered[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _tabButton(
            'Upcoming',
            isUpcoming,
                () => setState(() => isUpcoming = true),
          ),
          _tabButton(
            'Past Sessions',
            !isUpcoming,
                () => setState(() => isUpcoming = false),
          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final activeBtn = _activeButton[booking.bookingID];
    final session = booking.session;
    final coach = booking.coach;
    final past = _isPast(booking);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(coach.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              session.sportName,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(session.sessionDate)} • ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
            ),
            const SizedBox(height: 6),
            Text(
              booking.status,
              style: TextStyle(
                color: booking.status.toLowerCase() == 'confirmed'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionButton(
                  text: past ? 'Rate Coach' : 'Message Coach',
                  isActive: activeBtn == 'message',
                  onTap: () async {
                    setState(() => _activeButton[booking.bookingID] = 'message');

                    if (past) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RateSessionScreen(
                            onSubmitted: () {},
                          ),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: _coachUserId(booking),
                            name: coach.name,
                            isOnline: false,
                          ),
                        ),
                      );
                    }

                    if (mounted) {
                      setState(() => _activeButton.remove(booking.bookingID));
                    }
                  },
                ),
                const SizedBox(width: 12),
                _actionButton(
                  text: 'Details',
                  isActive: activeBtn == 'details',
                  onTap: () async {
                    setState(() => _activeButton[booking.bookingID] = 'details');

                    final detailsSession = BookingSessionModel(
                      id: booking.bookingID.toString(),
                      coachUserId: _coachUserId(booking),
                      coachName: coach.name,
                      sport: session.sportName,
                      location: session.location,
                      date: DateTime.tryParse(session.sessionDate) ??
                          DateTime.now(),
                      isPast: past,
                    );

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoachDetailsScreen(
                          session: detailsSession,
                          image: '',
                        ),
                      ),
                    );

                    if (mounted) {
                      setState(() => _activeButton.remove(booking.bookingID));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.primaryBlue : AppColors.disabledGray,
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _emptyCard(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 180),
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}