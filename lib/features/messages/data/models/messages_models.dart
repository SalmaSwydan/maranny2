// MESSAGES MODELS
// Use userId (from AspNetUsers), NOT clientID or coachID.

class SendMessageRequest {
  final int receiverId;
  final String content;

  const SendMessageRequest({required this.receiverId, required this.content});

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
    'content': content,
  };
}

class MessageModel {
  final int messageID;
  final int senderID;
  final int receiverID;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final double? latitude;
  final double? longitude;
  final String sentAt;
  final bool isRead;
  final String? readAt;
  final bool isMine;

  const MessageModel({
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    required this.isRead,
    required this.isMine,
    this.attachmentUrl,
    this.latitude,
    this.longitude,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageID: _asInt(json['messageID'] ?? json['messageId'] ?? json['id']),
    senderID: _asInt(json['senderID'] ?? json['senderId']),
    receiverID: _asInt(json['receiverID'] ?? json['receiverId']),
    content: _asString(json['content'] ?? json['message']),
    messageType: _asString(
      json['messageType'] ?? json['type'],
      fallback: 'text',
    ).toLowerCase(),
    attachmentUrl: _asNullableString(
      json['attachmentUrl'] ??
          json['attachmentURL'] ??
          json['mediaUrl'] ??
          json['imageUrl'] ??
          json['fileUrl'],
    ),
    latitude: _asNullableDouble(json['latitude'] ?? json['lat']),
    longitude: _asNullableDouble(json['longitude'] ?? json['lng']),
    sentAt: _asString(json['sentAt'] ?? json['createdAt']),
    isRead: _asBool(json['isRead'] ?? json['read']),
    isMine: _asBool(json['isMine'] ?? json['mine']),
    readAt: _asNullableString(json['readAt']),
  );
}

class ConversationModel {
  final int userId;
  final String name;
  final String? imageUrl;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ConversationModel({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    this.imageUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        userId: _asInt(json['userId'] ?? json['otherUserId'] ?? json['id']),
        name: _asString(json['name'] ?? json['fullName'], fallback: 'User'),
        imageUrl: _asNullableString(
          json['imageUrl'] ??
              json['profilePictureUrl'] ??
              json['profilePicture'] ??
              json['photoUrl'] ??
              json['avatarUrl'] ??
              json['url'],
        ),
        lastMessage: _asString(json['lastMessage']),
        lastMessageTime: _asString(json['lastMessageTime'] ?? json['sentAt']),
        unreadCount: _asInt(json['unreadCount']),
        isOnline: _asBool(json['isOnline']),
      );
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.trim().isEmpty ? null : text;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
