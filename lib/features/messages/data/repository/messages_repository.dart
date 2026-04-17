import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/messages_models.dart';

class MessagesRepository {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> sendMessage(
      SendMessageRequest request) async {
    final response = await _dio.post(
        ApiConfig.sendMessage, data: request.toJson());
    return response.data as Map<String, dynamic>;
  }

  Future<List<MessageModel>> getConversation(
      int otherUserId, {int page = 1, int pageSize = 50}) async {
    final response = await _dio.get(
      '/chat/conversation/$otherUserId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
        MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get(ApiConfig.conversations);
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
        ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int otherUserId) async {
    await _dio.put('/chat/conversation/$otherUserId/read');
  }

  Future<int> getUnreadCount({int? fromUserId}) async {
    final response = await _dio.get(
      ApiConfig.chatUnreadCount,
      queryParameters: {
        if (fromUserId != null) 'fromUserId': fromUserId,
      },
    );
    return response.data['unreadCount'] as int;
  }
}