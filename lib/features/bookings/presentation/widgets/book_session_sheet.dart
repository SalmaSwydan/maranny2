import 'package:flutter/material.dart';
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import '../screens/payment_screen.dart';

class BookSessionSheet extends StatefulWidget {
  final String coachName;
  final String coachSport;
  final String coachImage;
  final int coachPrice;

  const BookSessionSheet({
    super.key,
    this.coachName = 'Coach',
    this.coachSport = 'Coach',
    this.coachImage = '',
    this.coachPrice = 500,
  });

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  final BookingsRepository _repo = BookingsRepository();

  bool _isLoading = true;
  String? _error;
  List<SessionModel> _sessions = [];
  SessionModel? _selectedSession;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  int? _sportIdFromText(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('football')) return 1;
    if (s.contains('swimming')) return 2;
    if (s.contains('yoga')) return 3;
    if (s.contains('fitness')) return 4;
    if (s.contains('tennis')) return 5;
    if (s.contains('basketball')) return 6;
    if (s.contains('horse')) return 7;
    return null;
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repo.browseSessions(
        sportId: _sportIdFromText(widget.coachSport),
        page: 1,
        pageSize: 50,
      );

      if (!mounted) return;

      setState(() {
        _sessions = result.sessions.where((s) {
          final available = s.availableSlots ?? 1;
          return s.status.toLowerCase() != 'cancelled' && available > 0;
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load available sessions';
        _isLoading = false;
      });
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

  int get _price {
    if (widget.coachPrice > 0) return widget.coachPrice;
    return 500;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Available sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: TextButton(
                  onPressed: _loadSessions,
                  child: Text(_error!),
                ),
              )
                  : _sessions.isEmpty
                  ? const Center(
                child: Text(
                  'No available sessions yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  final selected =
                      _selectedSession?.sessionID ==
                          session.sessionID;

                  return GestureDetector(
                    onTap: () => setState(
                          () => _selectedSession = session,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF303F9F)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF303F9F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: selected
                                ? Colors.white
                                : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(
                                      session.sessionDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.location,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${session.availableSlots ?? 0} slots',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedSession == null
                    ? null
                    : () {
                  final s = _selectedSession!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        sessionID: s.sessionID,
                        day: _formatDate(s.sessionDate),
                        time:
                        '${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}',
                        coachName: widget.coachName,
                        coachSport: widget.coachSport,
                        coachImage: widget.coachImage,
                        coachPrice: _price,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303F9F),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}