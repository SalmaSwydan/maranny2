import 'package:dio/dio.dart';

/// ─────────────────────────────────────────────────────────────
/// AI CLIENT
/// Separate Dio instance for the AI recommendation service.
/// Different server from the main API (port 8000).
/// ─────────────────────────────────────────────────────────────
class AiClient {
  AiClient._();

  // ✅ Update this when AI service URL is ready
  static const String baseUrl = 'http://your-server:8000';

  static const String recommend = '/api/recommend';
  static const String health    = '/health';

  static final Dio _dio = _createDio();
  static Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept':        'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody:  true,
      responseBody: true,
      logPrint: (log) => print('[AI] $log'),
    ));

    return dio;
  }

  /// Check if AI service is alive before sending requests
  static Future<bool> isAlive() async {
    try {
      final response = await _dio.get(health);
      return response.data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}