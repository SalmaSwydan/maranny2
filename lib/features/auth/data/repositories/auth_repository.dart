import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/client_profile_storage.dart';
import '../../../../core/utils/user_preferences_storage.dart';
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
      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      await ClientProfileStorage.clear();
      await UserPreferencesStorage.clear();
      final response = await _dio.post(ApiConfig.login, data: request.toJson());
      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      await TokenStorage.saveUserType(loginResponse.user.userType);
      await TokenStorage.saveUserProfile(
        userId: loginResponse.user.id.toString(),
        email: loginResponse.user.email,
        firstName: loginResponse.user.firstName,
        lastName: loginResponse.user.lastName,
      );
      await ClientProfileStorage.clearLegacy();
      await UserPreferencesStorage.clearLegacy();
      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CompleteCoachOnboardingResponse> completeCoachOnboarding(
    CompleteCoachOnboardingRequest request,
  ) async {
    final requestBody = request.toJson();
    final requestUrl = _buildLogUrl(ApiConfig.completeCoachOnboarding);

    developer.log(
      'Coach onboarding request -> method=POST url=$requestUrl body=${jsonEncode(requestBody)}',
      name: 'AuthRepository',
    );

    try {
      final response = await _dio.post(
        ApiConfig.completeCoachOnboarding,
        data: requestBody,
      );
      developer.log(
        'Coach onboarding response -> status=${response.statusCode} body=${jsonEncode(response.data)}',
        name: 'AuthRepository',
      );
      return CompleteCoachOnboardingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      developer.log(
        'Coach onboarding error -> status=${e.response?.statusCode} body=${jsonEncode(e.response?.data)}',
        name: 'AuthRepository',
        error: e,
      );
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
      await ClientProfileStorage.clear();
      await UserPreferencesStorage.clear();
      await TokenStorage.clear();
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
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
        return ApiError.fromJson(e.response!.data as Map<String, dynamic>);
      } catch (_) {}
    }
    return ApiError(message: e.message ?? 'Network error. Please try again.');
  }

  String _buildLogUrl(String path) {
    final baseUrl = _dio.options.baseUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return '${baseUrl.substring(0, baseUrl.length - 1)}$path';
    }
    if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return '$baseUrl/$path';
    }
    return '$baseUrl$path';
  }
}
