import 'dart:convert';
import 'dart:developer' as developer;
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
    final requestUrl = _buildLogUrl(ApiConfig.uploadProfilePic);
    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'profile.jpg',
      ),
    });

    developer.log(
      'Upload profile picture request -> '
      'url=$requestUrl method=POST contentType=multipart/form-data '
      'fieldNames=${formData.fields.map((entry) => entry.key).toList(growable: false)} '
      'fileFieldNames=${formData.files.map((entry) => entry.key).toList(growable: false)}',
      name: 'ProfileRepository',
    );

    final response = await _dio.post(
      ApiConfig.uploadProfilePic,
      data: formData,
    );

    developer.log(
      'Upload profile picture response -> status=${response.statusCode} body=${jsonEncode(response.data)}',
      name: 'ProfileRepository',
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
    final responseData = response.data as Map<String, dynamic>;
    developer.log(
      'Coach profile response for coachId=$coachId -> ${jsonEncode(responseData)}',
      name: 'ProfileRepository',
    );

    final profile = CoachProfileModel.fromJson(responseData);
    developer.log(
      'Coach profile parsed for coachId=$coachId -> '
      'bio=${profile.resolvedBio ?? ''}, '
      'price=${profile.resolvedPrice?.toString() ?? ''}, '
      'location=${profile.resolvedLocation ?? ''}',
      name: 'ProfileRepository',
    );

    return profile;
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
    final queryParameters = <String, dynamic>{
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
    };
    final requestUrl = _buildLogUrl(ApiConfig.searchCoaches);
    final requestHeaders = _sanitizeHeaders(<String, dynamic>{
      ..._dio.options.headers,
    });

    developer.log(
      'Search coaches request -> '
      'url=$requestUrl '
      'method=GET '
      'headers=${jsonEncode(requestHeaders)} '
      'query=${jsonEncode(queryParameters)}',
      name: 'ProfileRepository',
    );
    print(
      '[ProfileRepository] Search coaches request -> '
      'url=$requestUrl '
      'method=GET '
      'headers=${jsonEncode(requestHeaders)} '
      'query=${jsonEncode(queryParameters)}',
    );

    final response = await _dio.get(
      ApiConfig.searchCoaches,
      queryParameters: queryParameters,
    );

    final data = response.data;
    final coaches = switch (data) {
      {'coaches': final List<dynamic> coaches} => coaches,
      {'items': final List<dynamic> items} => items,
      {'results': final List<dynamic> results} => results,
      {'data': final List<dynamic> data} => data,
      final List<dynamic> list => list,
      _ => <dynamic>[],
    };

    developer.log(
      'Search coaches response -> '
      'status=${response.statusCode} '
      'count=${coaches.length} '
      'body=${jsonEncode(response.data)}',
      name: 'ProfileRepository',
    );
    print(
      '[ProfileRepository] Search coaches response -> '
      'status=${response.statusCode} '
      'count=${coaches.length} '
      'body=${jsonEncode(response.data)}',
    );

    return coaches
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
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

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}
