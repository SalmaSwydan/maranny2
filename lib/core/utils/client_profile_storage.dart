import 'package:shared_preferences/shared_preferences.dart';

import '../network/token_storage.dart';

class ClientProfileStorage {
  ClientProfileStorage._();

  static const _kPhone = 'client_profile_phone';
  static const _kLocation = 'client_profile_location';
  static const _kBio = 'client_profile_bio';
  static const _kImageUrl = 'client_profile_image_url';
  static const _legacyKeys = <String>[_kPhone, _kLocation, _kBio, _kImageUrl];

  static Future<void> save({
    String? phone,
    String? location,
    String? bio,
    String? imageUrl,
  }) async {
    final scope = await _currentUserScope();
    if (scope == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (phone != null) await prefs.setString(_scopedKey(_kPhone, scope), phone);
    if (location != null) {
      await prefs.setString(_scopedKey(_kLocation, scope), location);
    }
    if (bio != null) await prefs.setString(_scopedKey(_kBio, scope), bio);
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      await prefs.setString(_scopedKey(_kImageUrl, scope), imageUrl);
    }
  }

  static Future<ClientProfileCache> load() async {
    final scope = await _currentUserScope();
    if (scope == null) return const ClientProfileCache();

    final prefs = await SharedPreferences.getInstance();
    return ClientProfileCache(
      phone: prefs.getString(_scopedKey(_kPhone, scope)),
      location: prefs.getString(_scopedKey(_kLocation, scope)),
      bio: prefs.getString(_scopedKey(_kBio, scope)),
      imageUrl: prefs.getString(_scopedKey(_kImageUrl, scope)),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = await _currentUserScope();
    if (scope != null) {
      for (final key in _legacyKeys) {
        await prefs.remove(_scopedKey(key, scope));
      }
    }
    await clearLegacy();
  }

  static Future<void> clearLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _legacyKeys) {
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

class ClientProfileCache {
  final String? phone;
  final String? location;
  final String? bio;
  final String? imageUrl;

  const ClientProfileCache({
    this.phone,
    this.location,
    this.bio,
    this.imageUrl,
  });
}
