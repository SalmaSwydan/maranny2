import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.dio;

  Future<String> updateProfile(UpdateProfileRequest request) async {
    final response = await _dio.put(
        ApiConfig.updateProfile, data: request.toJson());
    return response.data['message'] as String;
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
          imageFile.path, filename: 'profile.jpg'),
    });
    final response = await _dio.post(
        ApiConfig.uploadProfilePic, data: formData);
    return response.data['imageUrl'] as String;
  }

  Future<String> updatePreferences(
      UpdatePreferencesRequest request) async {
    final response = await _dio.put(
        ApiConfig.updatePreferences, data: request.toJson());
    return response.data['message'] as String;
  }

  Future<CoachProfileModel> getCoachProfile(int coachId) async {
    final response =
    await _dio.get('${ApiConfig.searchCoaches}/$coachId');
    return CoachProfileModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<String> changePassword(
      ChangePasswordRequest request) async {
    final response = await _dio.put(
        ApiConfig.changePassword, data: request.toJson());
    return response.data['message'] as String;
  }

  Future<Map<String, dynamic>> searchCoaches({
    String? name, int? sportID, String? city,
    double? minRating, int? minExperience, String? gender,
    bool? verifiedOnly, String? sortBy, String? sortOrder,
    int page = 1, int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.searchCoaches,
      queryParameters: {
        if (name != null)          'name':          name,
        if (sportID != null)       'sportID':       sportID,
        if (city != null)          'city':          city,
        if (minRating != null)     'minRating':     minRating,
        if (minExperience != null) 'minExperience': minExperience,
        if (gender != null)        'gender':        gender,
        if (verifiedOnly != null)  'verifiedOnly':  verifiedOnly,
        if (sortBy != null)        'sortBy':        sortBy,
        if (sortOrder != null)     'sortOrder':     sortOrder,
        'page': page, 'pageSize': pageSize,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}