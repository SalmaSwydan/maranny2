import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.dio;

  Future<String> updateProfile(UpdateProfileRequest request) async {
    final response = await _dio.put(
      ApiConfig.updateProfile,
      data: request.toJson(),
    );
    return response.data['message'] as String;
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'profile.jpg',
      ),
    });

    final response = await _dio.post(
      ApiConfig.uploadProfilePic,
      data: formData,
    );

    return response.data['imageUrl'] as String;
  }

  Future<String> updatePreferences(UpdatePreferencesRequest request) async {
    final response = await _dio.put(
      ApiConfig.updatePreferences,
      data: request.toJson(),
    );
    return response.data['message'] as String;
  }

  Future<CoachProfileModel> getCoachProfile(int coachId) async {
    final response = await _dio.get('${ApiConfig.searchCoaches}/$coachId');
    return CoachProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> changePassword(ChangePasswordRequest request) async {
    final response = await _dio.put(
      ApiConfig.changePassword,
      data: request.toJson(),
    );
    return response.data['message'] as String;
  }

  Future<List<Map<String, dynamic>>> searchCoachesList({
    String? name,
    int? sportID,
    String? city,
    double? minRating,
    int? minExperience,
    String? gender,
    bool? verifiedOnly,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.searchCoaches,
      queryParameters: {
        if (name != null && name.isNotEmpty) 'Name': name,
        if (sportID != null) 'SportID': sportID,
        if (city != null && city.isNotEmpty) 'City': city,
        if (minRating != null) 'MinRating': minRating,
        if (minExperience != null) 'MinExperience': minExperience,
        if (gender != null && gender.isNotEmpty) 'Gender': gender,
        if (verifiedOnly != null) 'VerifiedOnly': verifiedOnly,
        if (sortBy != null && sortBy.isNotEmpty) 'SortBy': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'SortOrder': sortOrder,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final coaches = data['coaches'] as List<dynamic>? ?? [];

    return coaches.map((e) => e as Map<String, dynamic>).toList();
  }
}