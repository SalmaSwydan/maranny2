import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';

class SettingsRepository {
  final Dio _dio = ApiClient.dio;

  Future<String> contactSupport({
    required String email,
    required String message,
  }) async {
    final response = await _dio.post(
      ApiConfig.contactSupport,
      data: {'email': email.trim(), 'message': message.trim()},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? 'Support request sent successfully.')
          .toString();
    }
    return 'Support request sent successfully.';
  }

  Future<String> submitReport({
    required String target,
    required String reason,
    required String description,
    required String reportedType,
  }) async {
    final response = await _dio.post(
      ApiConfig.reports,
      data: {
        'target': target.trim(),
        'reason': reason.trim(),
        'description': description.trim(),
        'reportedType': reportedType.trim(),
        'priority': 'Normal',
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? 'Report submitted successfully.').toString();
    }
    return 'Report submitted successfully.';
  }
}
