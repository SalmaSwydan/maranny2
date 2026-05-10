import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/messages_models.dart';

class MessagesRepository {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> sendMessage(SendMessageRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendMessage,
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      developer.log(
        'Send message failed -> status=${error.response?.statusCode} data=${error.response?.data}',
        name: 'MessagesRepository',
        error: error,
        stackTrace: error.stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendAttachment({
    required int receiverId,
    required String messageType,
    String? content,
    File? file,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final formData = FormData.fromMap({
        'ReceiverId': receiverId,
        'MessageType': messageType,
        if (content != null && content.trim().isNotEmpty)
          'Content': content.trim(),
        if (latitude != null) 'Latitude': latitude,
        if (longitude != null) 'Longitude': longitude,
        if (file != null)
          'File': await MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.isNotEmpty
                ? file.uri.pathSegments.last
                : 'chat_image.jpg',
          ),
      });

      developer.log(
        'Sending attachment -> type=$messageType receiverId=$receiverId file=${file?.path} lat=$latitude lng=$longitude',
        name: 'MessagesRepository',
      );

      final response = await _dio.post(
        ApiConfig.sendChatAttachment,
        data: formData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      developer.log(
        'Send attachment failed -> status=${error.response?.statusCode} data=${error.response?.data}',
        name: 'MessagesRepository',
        error: error,
        stackTrace: error.stackTrace,
      );
      rethrow;
    }
  }

  Future<List<MessageModel>> getConversation(
    int otherUserId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConfig.conversation(otherUserId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    final list = response.data as List<dynamic>;

    return list
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get(ApiConfig.conversations);

    final list = response.data as List<dynamic>;

    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int otherUserId) async {
    await _dio.put(ApiConfig.markConversationRead(otherUserId));
  }

  Future<int> getUnreadCount({int? fromUserId}) async {
    final response = await _dio.get(
      ApiConfig.chatUnreadCount,
      queryParameters: {if (fromUserId != null) 'fromUserId': fromUserId},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final value = data['unreadCount'] ?? data['count'] ?? data['total'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }
    if (data is int) return data;
    if (data is num) return data.toInt();
    return 0;
  }
}
