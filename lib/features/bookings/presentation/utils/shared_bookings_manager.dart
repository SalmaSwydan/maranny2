class SharedBookingsManager {
  SharedBookingsManager._();

  /// Single source of truth for all confirmed bookings (persists across navigation).
  static final List<Map<String, dynamic>> _confirmedBookings = [];

  static List<Map<String, dynamic>> _defaultBookings() {
    return [
      {
        'name': 'Ahmed Mohamed',
        'activity': 'Football',
        'date': 'Dec 17, 2025',
        'time': '10:00 AM - 11:00 AM',
        'location': 'Court 3',
        'price': '\$ 25/hr',
        'status': 'Confirmed',
      },
      {
        'name': 'Sarah Johnson',
        'activity': 'Football',
        'date': 'Dec 17, 2025',
        'time': '2:00 AM - 3:00 AM',
        'location': 'Court 3',
        'price': '\$ 25/hr',
        'status': 'Confirmed',
      },
    ];
  }

  /// Returns all confirmed bookings (seeds with defaults if empty). Does not clear.
  static List<Map<String, dynamic>> getConfirmedBookings() {
    if (_confirmedBookings.isEmpty) {
      _confirmedBookings.addAll(_defaultBookings());
    }
    return List<Map<String, dynamic>>.from(_confirmedBookings);
  }

  /// Add a confirmed booking (from home screen or from Pending Requests tab).
  static void addAcceptedBooking(Map<String, dynamic> booking) {
    _confirmedBookings.add(booking);
  }

  /// Remove a confirmed booking (e.g. when user cancels).
  static void removeConfirmedBooking(Map<String, dynamic> booking) {
    final name = booking['name'] as String?;
    final date = booking['date'] as String?;
    final time = booking['time'] as String?;
    if (name == null || date == null || time == null) return;
    _confirmedBookings.removeWhere((b) {
      return b['name'] == name && b['date'] == date && b['time'] == time;
    });
  }
}



