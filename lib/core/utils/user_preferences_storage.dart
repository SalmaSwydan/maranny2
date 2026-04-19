import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// USER PREFERENCES STORAGE
/// Saves the preferences the client set during onboarding
/// (ClientPreferencesScreen) so they are used automatically
/// in every AI recommendation request.
///
/// Usage:
///   // Save after onboarding:
///   await UserPreferencesStorage.save(
///     sports: ['Football', 'Swimming'],
///     budgetMin: 100,
///     budgetMax: 500,
///     city: 'Cairo',
///     ...
///   );
///
///   // Load before AI request:
///   final prefs = await UserPreferencesStorage.load();
/// ─────────────────────────────────────────────────────────────
class UserPreferencesStorage {
  UserPreferencesStorage._();

  // ── Keys ──────────────────────────────────────────────────
  static const _kSports        = 'pref_sports';        // comma-separated
  static const _kBudgetMin     = 'pref_budget_min';
  static const _kBudgetMax     = 'pref_budget_max';
  static const _kCity          = 'pref_city';
  static const _kArea          = 'pref_area';
  static const _kLocation      = 'pref_location';      // 'Anywhere' | 'My city'
  static const _kRating        = 'pref_rating';        // '4.5+' | '4.0+' | '3.0+' | null
  static const _kGender        = 'pref_gender';        // 'Male' | 'Female' | 'No Preference'
  static const _kAgeRange      = 'pref_age_range';     // '20-30' | '30-40' | '40+'
  static const _kCertified     = 'pref_certified';     // bool

  // ── Save ──────────────────────────────────────────────────
  static Future<void> save({
    List<String>? sports,
    double? budgetMin,
    double? budgetMax,
    String? city,
    String? area,
    String? locationPreference,
    String? ratingPreference,
    String? coachGender,
    String? coachAgeRange,
    bool certifiedOnly = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (sports != null)             await prefs.setString(_kSports,    sports.join(','));
    if (budgetMin != null)          await prefs.setDouble(_kBudgetMin, budgetMin);
    if (budgetMax != null)          await prefs.setDouble(_kBudgetMax, budgetMax);
    if (city != null)               await prefs.setString(_kCity,      city);
    if (area != null)               await prefs.setString(_kArea,      area);
    if (locationPreference != null) await prefs.setString(_kLocation,  locationPreference);
    if (ratingPreference != null)   await prefs.setString(_kRating,    ratingPreference);
    if (coachGender != null)        await prefs.setString(_kGender,    coachGender);
    if (coachAgeRange != null)      await prefs.setString(_kAgeRange,  coachAgeRange);
    await prefs.setBool(_kCertified, certifiedOnly);
  }

  // ── Load ──────────────────────────────────────────────────
  static Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();

    final sportsStr = prefs.getString(_kSports);
    final sports = sportsStr != null && sportsStr.isNotEmpty
        ? sportsStr.split(',')
        : <String>[];

    // Convert rating string to double for AI request
    final ratingStr = prefs.getString(_kRating);
    double? minRating;
    if (ratingStr == '4.5+') minRating = 4.5;
    else if (ratingStr == '4.0+') minRating = 4.0;
    else if (ratingStr == '3.0+') minRating = 3.0;

    return UserPreferences(
      sports:             sports,
      budgetMin:          prefs.getDouble(_kBudgetMin),
      budgetMax:          prefs.getDouble(_kBudgetMax),
      city:               prefs.getString(_kCity),
      area:               prefs.getString(_kArea),
      locationPreference: prefs.getString(_kLocation),
      minRating:          minRating,
      coachGender:        prefs.getString(_kGender),
      coachAgeRange:      prefs.getString(_kAgeRange),
      certifiedOnly:      prefs.getBool(_kCertified) ?? false,
    );
  }

  // ── Clear (on logout) ─────────────────────────────────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSports);
    await prefs.remove(_kBudgetMin);
    await prefs.remove(_kBudgetMax);
    await prefs.remove(_kCity);
    await prefs.remove(_kArea);
    await prefs.remove(_kLocation);
    await prefs.remove(_kRating);
    await prefs.remove(_kGender);
    await prefs.remove(_kAgeRange);
    await prefs.remove(_kCertified);
  }
}

// ── Preferences model ─────────────────────────────────────────
class UserPreferences {
  final List<String> sports;
  final double?      budgetMin;
  final double?      budgetMax;
  final String?      city;
  final String?      area;
  final String?      locationPreference;
  final double?      minRating;
  final String?      coachGender;
  final String?      coachAgeRange;
  final bool         certifiedOnly;

  const UserPreferences({
    required this.sports,
    this.budgetMin,
    this.budgetMax,
    this.city,
    this.area,
    this.locationPreference,
    this.minRating,
    this.coachGender,
    this.coachAgeRange,
    this.certifiedOnly = false,
  });

  bool get hasPreferences =>
      sports.isNotEmpty ||
          budgetMin != null ||
          city != null ||
          minRating != null;
}