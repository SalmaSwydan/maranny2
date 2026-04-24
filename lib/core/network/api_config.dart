/// ─────────────────────────────────────────────────────────────
/// API CONFIG
/// Single source of truth for all URLs and endpoint paths.
/// ─────────────────────────────────────────────────────────────
class ApiConfig {
  ApiConfig._();

  // ✅ Dev tunnel URL — works for everyone on any device
  static const String baseUrl = 'https://x4d1zblh-7112.uks1.devtunnels.ms/api';
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

  // ── Sessions endpoints ────────────────────────────────────
  static const String sessions = '/sessions';
  static const String mySessions = '/sessions/my';

  // ── Bookings endpoints ────────────────────────────────────
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';

  // ── Reviews endpoints ─────────────────────────────────────
  static const String reviews = '/reviews';

  // ── Search endpoints ──────────────────────────────────────
  static const String searchCoaches = '/search/coaches';

  // ── Payments endpoints ────────────────────────────────────
  static const String initiatePayment = '/payments/initiate';
  static const String myPayments = '/payments/my';

  // ── Notifications endpoints ───────────────────────────────
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';

  // ── Chat endpoints ────────────────────────────────────────
  // ── Chat endpoints ────────────────────────────────────────
  static const String sendMessage = '/chat/send';
  static const String conversations = '/chat/conversations';
  static const String conversation = '/chat/conversation';
  static const String markConversationRead = '/chat/conversation';
  static const String chatUnreadCount = '/chat/unread-count';

  // ── Marketplace endpoints ─────────────────────────────────
  static const String products = '/products';

  // ── Sports endpoints ──────────────────────────────────────
  static const String sports = '/sports';

  // ── Token lifetimes (for reference) ──────────────────────
  static const int accessTokenExpiryHours = 2;
  static const int refreshTokenExpiryDays = 7;
}
