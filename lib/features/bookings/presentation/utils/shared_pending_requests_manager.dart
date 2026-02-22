class SharedPendingRequestsManager {
  SharedPendingRequestsManager._();
  
  // Store all pending requests (shared between home and bookings screens)
  static final List<Map<String, dynamic>> _allPendingRequests = [
    {
      'name': 'Radwa Ali',
      'activity': 'Football',
      'date': 'Dec 18 at 3:00 PM',
      'status': "You're free",
    },
    {
      'name': 'Heba Ahmed',
      'activity': 'Football',
      'date': 'Dec 20 at 10:00 AM',
      'status': null, // No status
    },
    {
      'name': 'Alaa El Safy',
      'activity': 'Football',
      'date': 'Dec 13 at 7:00 PM',
      'status': "You're busy",
    },
    {
      'name': 'Ahmed Khaled',
      'activity': 'Football',
      'date': 'Dec 25 at 10:00 PM',
      'status': "You're free",
    },
  ];
  
  /// Get the next N pending requests (doesn't remove them, just returns a copy)
  static List<Map<String, dynamic>> getNextPendingRequests(int count) {
    final requests = <Map<String, dynamic>>[];
    
    for (var i = 0; i < _allPendingRequests.length && requests.length < count; i++) {
      requests.add(Map<String, dynamic>.from(_allPendingRequests[i]));
    }
    
    return requests;
  }
  
  /// Remove a specific pending request by name and date
  static void removePendingRequest(String name, String date) {
    _allPendingRequests.removeWhere(
      (request) => request['name'] == name && request['date'] == date,
    );
  }
  
  /// Get all pending requests without removing them
  static List<Map<String, dynamic>> getAllPendingRequests() {
    return List<Map<String, dynamic>>.from(_allPendingRequests);
  }
  
  /// Check if there are any pending requests left
  static bool hasPendingRequests() {
    return _allPendingRequests.isNotEmpty;
  }
  
  /// Get count of remaining pending requests
  static int getPendingRequestsCount() {
    return _allPendingRequests.length;
  }
}

