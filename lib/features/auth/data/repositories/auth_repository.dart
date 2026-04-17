import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/token_storage.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

/// ─────────────────────────────────────────────────────────────
/// AUTH REPOSITORY
/// One function per auth endpoint.
/// ─────────────────────────────────────────────────────────────
class AuthRepository {
  final Dio _dio = ApiClient.dio;

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: request.toJson(),
      );
      return RegisterResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(
          response.data as Map<String, dynamic>);
      await TokenStorage.saveTokens(
        accessToken:  loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      await TokenStorage.saveUserType(loginResponse.user.userType);
      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(
          ApiConfig.logout,
          data: LogoutRequest(refreshToken: refreshToken).toJson(),
        );
      }
    } catch (_) {
    } finally {
      await TokenStorage.clear();
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      return UserModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPassword,
        data: ForgotPasswordRequest(email: email).toJson(),
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.resetPassword,
        data: request.toJson(),
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiError _handleError(DioException e) {
    if (e.response?.data != null) {
      try {
        return ApiError.fromJson(
            e.response!.data as Map<String, dynamic>);
      } catch (_) {}
    }
    return ApiError(
        message: e.message ?? 'Network error. Please try again.');
  }
}