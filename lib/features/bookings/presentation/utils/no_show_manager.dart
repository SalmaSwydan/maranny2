/// Tracks no-show counts per client for the coach side.
/// When a client reaches [restrictionThreshold] no-shows,
/// they are flagged as restricted on the coach's view.
class NoShowManager {
  NoShowManager._();

  static const int restrictionThreshold = 3;

  // clientName → no-show count
  static final Map<String, int> _counts = {};

  // clientName → session-level status: 'attended' | 'no_show'
  // key = "$clientName|$date|$time"
  static final Map<String, String> _sessionStatus = {};

  // ── No-show count ──────────────────────────────────────────

  static void markNoShow(String clientName) {
    _counts[clientName] = (_counts[clientName] ?? 0) + 1;
  }

  static void markAttended(String clientName) {
    // If they were previously marked no-show for this call, decrement
    final current = _counts[clientName] ?? 0;
    if (current > 0) _counts[clientName] = current - 1;
  }

  static int getCount(String clientName) => _counts[clientName] ?? 0;

  static bool isRestricted(String clientName) =>
      getCount(clientName) >= restrictionThreshold;

  static Map<String, int> getAllCounts() => Map.unmodifiable(_counts);

  // ── Per-session status ─────────────────────────────────────

  static String _key(String name, String date, String time) =>
      '$name|$date|$time';

  /// Returns 'none', 'attended', or 'no_show'
  static String getSessionStatus(
      String clientName, String date, String time) =>
      _sessionStatus[_key(clientName, date, time)] ?? 'none';

  static void setSessionNoShow(
      String clientName, String date, String time) {
    final k = _key(clientName, date, time);
    final prev = _sessionStatus[k];
    _sessionStatus[k] = 'no_show';
    // Only increment if not already marked no-show
    if (prev != 'no_show') markNoShow(clientName);
    // If switching from attended → no-show, no extra decrement needed
  }

  static void setSessionAttended(
      String clientName, String date, String time) {
    final k = _key(clientName, date, time);
    final prev = _sessionStatus[k];
    _sessionStatus[k] = 'attended';
    // If switching from no-show → attended, decrement
    if (prev == 'no_show') markAttended(clientName);
  }

  static void reset() {
    _counts.clear();
    _sessionStatus.clear();
  }
}