/// ─────────────────────────────────────────────────────────────
/// API CONFIG
/// Single source of truth for all URLs and endpoint paths.
/// ─────────────────────────────────────────────────────────────
class ApiConfig {
  ApiConfig._();
  // ✅ Dev tunnel URL — works for everyone on any device
  static const String baseUrl = 'https://bb4n5c63-7112.uks1.devtunnels.ms/api';

  static String get publicBaseUrl => baseUrl.endsWith('/api')
      ? baseUrl.substring(0, baseUrl.length - 4)
      : baseUrl;

  static String resolveMediaUrl(String? rawPath) {
    final value = rawPath?.trim() ?? '';
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value)) {
      return value;
    }
    if (value.startsWith('/')) {
      return '$publicBaseUrl$value';
    }
    return '$publicBaseUrl/$value';
  }

  // ── Auth endpoints ────────────────────────────────────────
  static const String register = '/auth/register';
  static const String completeCoachOnboarding =
      '/auth/coach-onboarding/complete';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google-login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String confirmEmail = '/auth/confirm-email';
  static const String resendConfirmation = '/auth/resend-confirmation';

  // ── User endpoints ────────────────────────────────────────
  static const String updateProfile = '/users/profile';
  static const String uploadProfilePic = '/users/profile/image';
  static const String updatePreferences = '/users/preferences';
  static const String coachSetup = '/users/coach-setup';

  // ── Sessions endpoints ────────────────────────────────────
  static const String sessions = '/sessions';
  static const String mySessions = '/sessions/my';
  static const String sessionsAvailability = '/sessions/availability';

  // ── Bookings endpoints ────────────────────────────────────
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';
  static const String coachMyBookings = '/bookings/coach/my';

  // ── Reviews endpoints ─────────────────────────────────────
  static const String reviews = '/reviews';
  static const String myCoachReviews = '/reviews/my-coach-reviews';
  static String coachReviews(int coachId) => '/reviews/coach/$coachId';
  static String bookingReview(int bookingId) => '/bookings/$bookingId/review';
  static String reviewResponse(int reviewId) => '/reviews/$reviewId/response';

  // ── Search endpoints ──────────────────────────────────────
  static const String searchCoaches = '/search/coaches';

  // ── Payments endpoints ────────────────────────────────────
  static const String initiatePayment = '/payments/initiate';
  static const String myPayments = '/payments/my';
  static String paymentById(int paymentId) => '/payments/$paymentId';

  // ── Notifications endpoints ───────────────────────────────
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static String notificationRead(int notificationId) =>
      '/notifications/$notificationId/read';

  // ── Chat endpoints ────────────────────────────────────────
  // ── Chat endpoints ────────────────────────────────────────
  static const String sendMessage = '/chat/send';
  static const String sendChatAttachment = '/chat/send-attachment';
  static const String conversations = '/chat/conversations';
  static String conversation(int otherUserId) =>
      '/chat/conversation/$otherUserId';
  static String markConversationRead(int otherUserId) =>
      '/chat/conversation/$otherUserId/read';
  static String messageReaction(int messageId) =>
      '/chat/messages/$messageId/reaction';
  static const String chatUnreadCount = '/chat/unread-count';

  // ── Marketplace endpoints ─────────────────────────────────
  static const String products = '/products';
  static String productById(int productId) => '/products/$productId';

  // ── Sports endpoints ──────────────────────────────────────
  static const String sports = '/sports';

  // ── Token lifetimes (for reference) ──────────────────────
  static const int accessTokenExpiryHours = 2;
  static const int refreshTokenExpiryDays = 7;
}
