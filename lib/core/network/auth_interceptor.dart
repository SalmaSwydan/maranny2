import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'api_config.dart';

/// ─────────────────────────────────────────────────────────────
/// AUTH INTERCEPTOR
/// 1. Adds Authorization: Bearer {token} to every request
/// 2. When 401 → refreshes token silently
/// 3. Retries original request with new token
/// 4. If refresh fails → clears tokens (user must login again)
/// ─────────────────────────────────────────────────────────────
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final accessToken  = await TokenStorage.getAccessToken();
        final refreshToken = await TokenStorage.getRefreshToken();

        if (refreshToken == null) {
          await TokenStorage.clear();
          return handler.next(err);
        }

        final response = await _dio.post(
          '${ApiConfig.baseUrl}${ApiConfig.refresh}',
          data: {
            'accessToken':  accessToken,
            'refreshToken': refreshToken,
          },
        );

        final newAccess  = response.data['accessToken']  as String;
        final newRefresh = response.data['refreshToken'] as String;
        await TokenStorage.saveTokens(
          accessToken:  newAccess,
          refreshToken: newRefresh,
        );

        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await TokenStorage.clear();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}