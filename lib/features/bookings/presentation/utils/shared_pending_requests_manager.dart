/// Legacy in-memory pending request manager kept for compatibility.
///
/// Coach request screens now load real pending bookings from the API. This
/// manager intentionally starts empty to avoid showing fake client requests.
class SharedPendingRequestsManager {
  SharedPendingRequestsManager._();

  static final List<Map<String, dynamic>> _allPendingRequests = [];

  static List<Map<String, dynamic>> getNextPendingRequests(int count) {
    return _allPendingRequests
        .take(count)
        .map((request) => Map<String, dynamic>.from(request))
        .toList(growable: false);
  }

  static void removePendingRequest(String name, String date) {
    _allPendingRequests.removeWhere(
      (request) => request['name'] == name && request['date'] == date,
    );
  }

  static List<Map<String, dynamic>> getAllPendingRequests() {
    return _allPendingRequests
        .map((request) => Map<String, dynamic>.from(request))
        .toList(growable: false);
  }

  static bool hasPendingRequests() => _allPendingRequests.isNotEmpty;

  static int getPendingRequestsCount() => _allPendingRequests.length;
}
