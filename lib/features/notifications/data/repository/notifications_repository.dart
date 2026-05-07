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
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
        NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConfig.unreadCount);
    return response.data['unreadCount'] as int;
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.put(ApiConfig.notificationRead(notificationId));
  }
}
