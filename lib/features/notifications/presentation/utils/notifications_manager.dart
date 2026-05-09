/// Legacy in-memory notification manager kept only for older screens.
///
/// Real notification screens should use the API repository instead. This class
/// intentionally does not seed fake notifications, so empty states stay honest.
class NotificationsManager {
  NotificationsManager._();

  static final List<Map<String, dynamic>> _newNotifications = [];
  static final List<Map<String, dynamic>> _earlierNotifications = [];

  static List<Map<String, dynamic>> getNewNotifications() {
    return List<Map<String, dynamic>>.from(_newNotifications);
  }

  static List<Map<String, dynamic>> getEarlierNotifications() {
    return List<Map<String, dynamic>>.from(_earlierNotifications);
  }

  static void clearAll() {
    _newNotifications.clear();
    _earlierNotifications.clear();
  }

  static bool get hasAny =>
      _newNotifications.isNotEmpty || _earlierNotifications.isNotEmpty;
}
