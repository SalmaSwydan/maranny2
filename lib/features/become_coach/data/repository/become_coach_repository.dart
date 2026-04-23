import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../model/become_coach_models.dart';

class BecomeCoachRepository {
  BecomeCoachRepository();

  final Dio _dio = ApiClient.dio;

  Future<CompleteCoachOnboardingResponse> completeCoachOnboarding(
      CompleteCoachOnboardingRequest request,
      ) async {
    try {
      final response = await _dio.post(
        '/auth/coach-onboarding/complete',
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return CompleteCoachOnboardingResponse.fromJson(response.data);
      }

      return CompleteCoachOnboardingResponse(
        message: 'Coach onboarding completed successfully',
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['error'] != null) {
        return data['error'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] is List) {
        final errors = (data['errors'] as List)
            .map((e) => e.toString())
            .join('\n');
        if (errors.isNotEmpty) return errors;
      }

      if (data['errors'] is Map) {
        final buffer = StringBuffer();
        final errorsMap = data['errors'] as Map;

        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List) {
            for (final item in value) {
              buffer.writeln(item.toString());
            }
          } else {
            buffer.writeln(value.toString());
          }
        }

        final result = buffer.toString().trim();
        if (result.isNotEmpty) return result;
      }
    }

    return 'Failed to complete coach onboarding';
  }
}