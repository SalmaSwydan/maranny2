import 'package:shared_preferences/shared_preferences.dart';

// FILE: lib/features/profile/presentation/utils/coach_profile_manager.dart
// ✅ Persists coach profile data across sessions using shared_preferences

class CoachProfileManager {
  CoachProfileManager._();

  // ── Keys ──────────────────────────────────────────
  static const _kName      = 'coach_name';
  static const _kEmail     = 'coach_email';
  static const _kPhone     = 'coach_phone';
  static const _kLocation  = 'coach_location';
  static const _kBio       = 'coach_bio';
  static const _kPrice     = 'coach_price';
  static const _kImage     = 'coach_image';
  static const _kYears     = 'coach_years';

  // ── In-memory cache (loaded from prefs on app start) ──
  static String? profileImagePath;
  static String fullName       = 'Ahmed Mohamed';
  static String email          = 'ahmed.mohamed@example.com';
  static String location       = 'Cairo';
  static String phone          = '+20 100 123 567';
  static String bio            = 'Lorem ipsum dolor sit amet consectetur. Dolor at est at luctus volutpat aliquet ligula lectus egestas.';
  static int    yearsOfExperience = 3;
  static String sessionPrice   = '500 LE / hour';
  static final List<Map<String, String>> certificates = [];

  // ── Load from SharedPreferences (call once at app start) ──
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    fullName          = prefs.getString(_kName)     ?? fullName;
    email             = prefs.getString(_kEmail)    ?? email;
    phone             = prefs.getString(_kPhone)    ?? phone;
    location          = prefs.getString(_kLocation) ?? location;
    bio               = prefs.getString(_kBio)      ?? bio;
    sessionPrice      = prefs.getString(_kPrice)    ?? sessionPrice;
    profileImagePath  = prefs.getString(_kImage);
    yearsOfExperience = prefs.getInt(_kYears)       ?? yearsOfExperience;
  }

  // ── Save to SharedPreferences ──
  static Future<void> saveProfile({
    String? imagePath,
    String? name,
    String? emailVal,
    String? locationVal,
    String? phoneVal,
    String? bioVal,
    int?    years,
    String? price,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null && name.isNotEmpty) {
      fullName = name;
      await prefs.setString(_kName, name);
    }
    if (emailVal != null && emailVal.isNotEmpty) {
      email = emailVal;
      await prefs.setString(_kEmail, emailVal);
    }
    if (locationVal != null && locationVal.isNotEmpty) {
      location = locationVal;
      await prefs.setString(_kLocation, locationVal);
    }
    if (phoneVal != null && phoneVal.isNotEmpty) {
      phone = phoneVal;
      await prefs.setString(_kPhone, phoneVal);
    }
    if (bioVal != null) {
      bio = bioVal;
      await prefs.setString(_kBio, bioVal);
    }
    if (years != null) {
      yearsOfExperience = years;
      await prefs.setInt(_kYears, years);
    }
    if (price != null && price.isNotEmpty) {
      sessionPrice = price;
      await prefs.setString(_kPrice, price);
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImagePath = imagePath;
      await prefs.setString(_kImage, imagePath);
    }
  }

  static void addCertificate(String filePath, String displayName) {
    certificates.add({'path': filePath, 'name': displayName});
  }

  static void clearCertificates() {
    certificates.clear();
  }
}