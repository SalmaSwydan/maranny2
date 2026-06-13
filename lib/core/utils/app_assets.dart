/// ─────────────────────────────────────────────────────────────
/// APP ASSETS — single source of truth for all asset paths
///
/// Never use raw strings like 'assets/images/...' in screens.
/// Always use AppAssets.xxx
///
/// Usage:
///   Image.asset(AppAssets.marannyLogo)
///   SvgPicture.asset(AppAssets.homeIcon)
/// ─────────────────────────────────────────────────────────────
class AppAssets {
  AppAssets._();

  // ═══════════════════════════════════════════════════════════
  // IMAGES
  // ═══════════════════════════════════════════════════════════

  static const String _img = 'assets/images';

  /// Full-screen background used on auth screens
  static const String backgroundScreen = '$_img/background_screen.png';

  /// App logo — used on splash, auth screens
  static const String marannyLogo = '$_img/maranny_logo.png';

  // ── Coach profile photos ─────────────────────────────────
  static const String coachAhmedMohamed = '$_img/coach_ahmed_mohamed.png';
  static const String coachSarahAhmed = '$_img/coach_sarah_Ahmed.jpeg';
  static const String coach2 = '$_img/coach2.jpeg';
  static const String ahmedAliProfile = '$_img/AhmedAli_pp.png';
  static const String ziadMarwanPadel = '$_img/ZiadMarwanPADEL.jpeg';

  // ── Sport / activity images ──────────────────────────────
  static const String professionalFootball = '$_img/professional_football.png';
  static const String swimmingGoggles = '$_img/swimming_goggles.png';
  static const String basketballShoes = '$_img/basketball_shoes.png';
  static const String horseriding = '$_img/horseriding.jpeg';

  // ═══════════════════════════════════════════════════════════
  // ICONS (SVG unless noted)
  // ═══════════════════════════════════════════════════════════

  static const String _ico = 'assets/icons';

  // ── Bottom navigation ─────────────────────────────────────
  static const String homeIcon = '$_ico/home_icon.svg';
  static const String homeIconSelected = '$_ico/home_icon_selected.svg';
  static const String bookingIcon = '$_ico/booking_icon.svg';
  static const String bookingsIconSelected = '$_ico/bookings_icon_selected.svg';
  static const String messageIcon = '$_ico/message_icon.svg';
  static const String messagesIconSelected = '$_ico/messages_icon_selected.svg';
  static const String profileIcon = '$_ico/profile_icons.svg';
  static const String profileIconSelected = '$_ico/profile_icon_selected.svg';
  static const String marketplaceIcon = '$_ico/marketplace_icon_selected.svg';

  // ── Coach profile page icons ─────────────────────────────
  static const String coachProfileIcon1 = '$_ico/icon_1_coach_profile.svg';
  static const String coachProfileIcon2 =
      '$_ico/icon_2_coach_profile.png'; // PNG
  static const String coachProfileIcon3 =
      '$_ico/icon_3_coach_profile.png'; // PNG

  // ── Feature icons ─────────────────────────────────────────
  static const String locationIcon = '$_ico/location_icon.svg';
  static const String findNearbyIcon = '$_ico/find_nearby.svg';
  static const String bookSessionIcon = '$_ico/book_session.svg';
  static const String recommendationIcon = '$_ico/recommendation_icon.svg';
  static const String smartRecommendation = '$_ico/smart_Recommendation.svg';
  static const String userReviewIcon = '$_ico/userReview_icon.svg';
  static const String verifiedCoachesIcon = '$_ico/verified_Coaches.svg';
  static const String rightArrowIcon = '$_ico/right_icon.svg';
}
