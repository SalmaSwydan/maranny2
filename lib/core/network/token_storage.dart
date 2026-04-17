import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ─────────────────────────────────────────────────────────────
/// TOKEN STORAGE
/// Saves and reads tokens securely on the device.
/// ─────────────────────────────────────────────────────────────
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccess  = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyUser    = 'user_type'; // 'Client' | 'Coach'

  // ── Save ──────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccess,  value: accessToken);
    await _storage.write(key: _keyRefresh, value: refreshToken);
  }

  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: _keyUser, value: userType);
  }

  // ── Read ──────────────────────────────────────────────────
  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccess);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefresh);

  static Future<String?> getUserType() =>
      _storage.read(key: _keyUser);

  static Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Clear (on logout) ─────────────────────────────────────
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}