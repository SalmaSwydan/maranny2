/// Legacy in-memory confirmed bookings manager kept for compatibility.
///
/// Booking screens now load real bookings from the API. This class intentionally
/// starts empty so fake sessions never appear as real bookings.
class SharedBookingsManager {
  SharedBookingsManager._();

  static final List<Map<String, dynamic>> _confirmedBookings = [];

  static List<Map<String, dynamic>> getConfirmedBookings() {
    return List<Map<String, dynamic>>.from(_confirmedBookings);
  }

  static void addAcceptedBooking(Map<String, dynamic> booking) {
    _confirmedBookings.add(Map<String, dynamic>.from(booking));
  }

  static void removeConfirmedBooking(Map<String, dynamic> booking) {
    final name = booking['name'] as String?;
    final date = booking['date'] as String?;
    final time = booking['time'] as String?;
    if (name == null || date == null || time == null) return;

    _confirmedBookings.removeWhere(
      (item) =>
          item['name'] == name && item['date'] == date && item['time'] == time,
    );
  }
}
