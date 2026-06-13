import 'package:dio/dio.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';

/// ─────────────────────────────────────────────────────────────
/// API CLIENT
/// One single Dio instance for the whole app.
/// ─────────────────────────────────────────────────────────────
class ApiClient {
  ApiClient._();

  static final Dio _dio = _createDio();
  static Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 180),
        sendTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => print('[API] $log'),
      ),
    );

    return dio;
  }
}
