import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/notifications_models.dart';

class NotificationsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<NotificationModel>> getNotifications(
      {bool unreadOnly = false}) async {
    final response = await _dio.get(
      ApiConfig.notifications,
      queryParameters: {'unreadOnly': unreadOnly},
    );

    final data = response.data;
    final list = switch (data) {
      final List<dynamic> values => values,
      {'notifications': final List<dynamic> values} => values,
      {'items': final List<dynamic> values} => values,
      {'data': final List<dynamic> values} => values,
      _ => const <dynamic>[],
    };

    return list
        .map((e) =>
        NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConfig.unreadCount);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final count = data['unreadCount'] ?? data['count'] ?? data['total'];
      if (count is int) return count;
      if (count is num) return count.toInt();
      if (count is String) return int.tryParse(count) ?? 0;
    }
    return 0;
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.put(ApiConfig.notificationRead(notificationId));
  }
}
