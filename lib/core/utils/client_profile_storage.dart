import 'package:shared_preferences/shared_preferences.dart';

class ClientProfileStorage {
  ClientProfileStorage._();

  static const _kPhone = 'client_profile_phone';
  static const _kLocation = 'client_profile_location';
  static const _kBio = 'client_profile_bio';
  static const _kImageUrl = 'client_profile_image_url';

  static Future<void> save({
    String? phone,
    String? location,
    String? bio,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (phone != null) await prefs.setString(_kPhone, phone);
    if (location != null) await prefs.setString(_kLocation, location);
    if (bio != null) await prefs.setString(_kBio, bio);
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      await prefs.setString(_kImageUrl, imageUrl);
    }
  }

  static Future<ClientProfileCache> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ClientProfileCache(
      phone: prefs.getString(_kPhone),
      location: prefs.getString(_kLocation),
      bio: prefs.getString(_kBio),
      imageUrl: prefs.getString(_kImageUrl),
    );
  }
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
