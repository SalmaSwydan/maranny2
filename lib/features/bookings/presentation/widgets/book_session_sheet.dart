import 'package:flutter/material.dart';
import '../screens/payment_screen.dart';

class BookSessionSheet extends StatefulWidget {
  // ✅ Accept coach info to pass to PaymentScreen
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
  final Set<String> _selectedSlots = {};

  static const Map<String, int> _priceMap = {
    'Ahmed Mohamed': 500,
    'Sarah Ahmed': 400,
    'Sara Ahmed': 400,
    'Nancy Ali': 350,
    'Ziad Marwan': 600,
    'Omar Khaled': 300,
  };

  int get _resolvedPrice {
    if (widget.coachPrice > 25) return widget.coachPrice;
    return _priceMap[widget.coachName] ?? widget.coachPrice;
  }

  final Map<String, List<String>> _schedule = {
    'Saturday':  ['9:00 AM', '11:00 AM'],
    'Sunday':    ['10:00 AM'],
    'Monday':    ['10:00 AM', '2:00 PM', '5:00 PM'],
    'Tuesday':   ['10:00 AM', '3:00 PM', '6:00 PM'],
    'Wednesday': ['4:00 PM', '7:00 PM'],
    'Thursday':  ['2:00 PM', '10:00 PM'],
  };

  String _slotKey(String day, String time) => '$day|$time';
  bool _isSelected(String day, String time) =>
      _selectedSlots.contains(_slotKey(day, time));

  void _toggleSlot(String day, String time) {
    setState(() {
      final key = _slotKey(day, time);
      if (_selectedSlots.contains(key)) {
        _selectedSlots.remove(key);
      } else {
        _selectedSlots.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text('Available days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          ..._schedule.entries.map((e) => _dayRow(e.key, e.value)),

          const SizedBox(height: 16),

          if (_selectedSlots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${_selectedSlots.length} slot${_selectedSlots.length > 1 ? 's' : ''} selected',
                style: const TextStyle(
                    color: Color(0xFF303F9F), fontWeight: FontWeight.w600),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedSlots.isEmpty
                  ? null
                  : () {
                final firstSlot = _selectedSlots.first.split('|');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      day: firstSlot[0],
                      time: firstSlot[1],
                      coachName: widget.coachName,
                      coachSport: widget.coachSport,
                      coachImage: widget.coachImage,
                      coachPrice: _resolvedPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303F9F),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _selectedSlots.isEmpty
                    ? 'Book Now'
                    : 'Book Now (${_selectedSlots.length})',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dayRow(String day, List<String> times) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(day,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Wrap(
                children: times.map((t) => _timeButton(day, t)).toList(),
              ),
            ),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _timeButton(String day, String time) {
    final selected = _isSelected(day, time);
    return GestureDetector(
      onTap: () => _toggleSlot(day, time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF303F9F) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: selected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
