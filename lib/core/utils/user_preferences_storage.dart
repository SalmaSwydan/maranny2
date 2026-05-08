import 'package:shared_preferences/shared_preferences.dart';

import '../network/token_storage.dart';

/// Saves the preferences the client set during onboarding/profile editing.
/// Values are scoped per logged-in user so a new account never inherits
/// another account's local sports, budget, or location data.
class UserPreferencesStorage {
  UserPreferencesStorage._();

  static const _kSports = 'pref_sports';
  static const _kBudgetMin = 'pref_budget_min';
  static const _kBudgetMax = 'pref_budget_max';
  static const _kCity = 'pref_city';
  static const _kArea = 'pref_area';
  static const _kLocation = 'pref_location';
  static const _kRating = 'pref_rating';
  static const _kGender = 'pref_gender';
  static const _kAgeRange = 'pref_age_range';
  static const _kCertified = 'pref_certified';

  static const _keys = <String>[
    _kSports,
    _kBudgetMin,
    _kBudgetMax,
    _kCity,
    _kArea,
    _kLocation,
    _kRating,
    _kGender,
    _kAgeRange,
    _kCertified,
  ];

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
    final scope = await _currentUserScope();
    if (scope == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (sports != null) {
      await prefs.setString(_scopedKey(_kSports, scope), sports.join(','));
    }
    if (budgetMin != null) {
      await prefs.setDouble(_scopedKey(_kBudgetMin, scope), budgetMin);
    }
    if (budgetMax != null) {
      await prefs.setDouble(_scopedKey(_kBudgetMax, scope), budgetMax);
    }
    if (city != null) await prefs.setString(_scopedKey(_kCity, scope), city);
    if (area != null) await prefs.setString(_scopedKey(_kArea, scope), area);
    if (locationPreference != null) {
      await prefs.setString(_scopedKey(_kLocation, scope), locationPreference);
    }
    if (ratingPreference != null) {
      await prefs.setString(_scopedKey(_kRating, scope), ratingPreference);
    }
    if (coachGender != null) {
      await prefs.setString(_scopedKey(_kGender, scope), coachGender);
    }
    if (coachAgeRange != null) {
      await prefs.setString(_scopedKey(_kAgeRange, scope), coachAgeRange);
    }
    await prefs.setBool(_scopedKey(_kCertified, scope), certifiedOnly);
  }

  static Future<UserPreferences> load() async {
    final scope = await _currentUserScope();
    if (scope == null) return const UserPreferences(sports: <String>[]);

    final prefs = await SharedPreferences.getInstance();
    final sportsStr = prefs.getString(_scopedKey(_kSports, scope));
    final sports = sportsStr != null && sportsStr.isNotEmpty
        ? sportsStr
              .split(',')
              .map((sport) => sport.trim())
              .where((sport) => sport.isNotEmpty)
              .toList(growable: false)
        : <String>[];

    final ratingStr = prefs.getString(_scopedKey(_kRating, scope));
    double? minRating;
    if (ratingStr == '4.5+') {
      minRating = 4.5;
    } else if (ratingStr == '4.0+') {
      minRating = 4.0;
    } else if (ratingStr == '3.0+') {
      minRating = 3.0;
    }

    return UserPreferences(
      sports: sports,
      budgetMin: prefs.getDouble(_scopedKey(_kBudgetMin, scope)),
      budgetMax: prefs.getDouble(_scopedKey(_kBudgetMax, scope)),
      city: prefs.getString(_scopedKey(_kCity, scope)),
      area: prefs.getString(_scopedKey(_kArea, scope)),
      locationPreference: prefs.getString(_scopedKey(_kLocation, scope)),
      minRating: minRating,
      coachGender: prefs.getString(_scopedKey(_kGender, scope)),
      coachAgeRange: prefs.getString(_scopedKey(_kAgeRange, scope)),
      certifiedOnly: prefs.getBool(_scopedKey(_kCertified, scope)) ?? false,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _currentUserScope();
    if (scope != null) {
      for (final key in _keys) {
        await prefs.remove(_scopedKey(key, scope));
      }
    }
    await clearLegacy();
  }

  static Future<void> clearLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _keys) {
      await prefs.remove(key);
    }
  }

  static Future<String?> _currentUserScope() async {
    final userId = (await TokenStorage.getUserId())?.trim();
    if (userId != null && userId.isNotEmpty) {
      return 'user_$userId';
    }

    final email = (await TokenStorage.getEmail())?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      final safeEmail = email.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      return 'email_$safeEmail';
    }

    return null;
  }

  static String _scopedKey(String key, String scope) => '${key}_$scope';
}

class UserPreferences {
  final List<String> sports;
  final double? budgetMin;
  final double? budgetMax;
  final String? city;
  final String? area;
  final String? locationPreference;
  final double? minRating;
  final String? coachGender;
  final String? coachAgeRange;
  final bool certifiedOnly;

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
