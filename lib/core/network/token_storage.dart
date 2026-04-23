import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ─────────────────────────────────────────────────────────────
/// TOKEN STORAGE
/// Saves and reads tokens securely on the device.
/// ─────────────────────────────────────────────────────────────
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyUser = 'user_type'; // 'Client' | 'Coach'
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'user_email';
  static const _keyFirstName = 'user_first_name';
  static const _keyLastName = 'user_last_name';

  // ── Save ──────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccess, value: accessToken);
    await _storage.write(key: _keyRefresh, value: refreshToken);
  }

  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: _keyUser, value: userType);
  }

  static Future<void> saveUserProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
  }

  // ── Read ──────────────────────────────────────────────────
  static Future<String?> getAccessToken() => _storage.read(key: _keyAccess);

  static Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);

  static Future<String?> getUserType() => _storage.read(key: _keyUser);

  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<String?> getEmail() => _storage.read(key: _keyEmail);

  static Future<String?> getFirstName() => _storage.read(key: _keyFirstName);

  static Future<String?> getLastName() => _storage.read(key: _keyLastName);

  static Future<String?> getDisplayName() async {
    final firstName = await getFirstName();
    final lastName = await getLastName();
    final fullName = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = await getEmail();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return null;
  }

  static Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Clear (on logout) ─────────────────────────────────────
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
