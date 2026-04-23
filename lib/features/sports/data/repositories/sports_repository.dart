import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/sport_model.dart';

class SportsRepository {
  final Dio _dio = ApiClient.dio;
  List<SportModel>? _cache;

  Future<List<SportModel>> getSports({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }

    final response = await _dio.get(ApiConfig.sports);
    final sports = (response.data as List<dynamic>)
        .map((item) => SportModel.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    _cache = sports;
    return sports;
  }
}
