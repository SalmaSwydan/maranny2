/// ─────────────────────────────────────────────────────────────
/// MESSAGES MODELS
/// ⚠️ Use userId (from AspNetUsers), NOT clientID or coachID
/// ─────────────────────────────────────────────────────────────

class SendMessageRequest {
  final int    receiverId;
  final String content;

  const SendMessageRequest(
      {required this.receiverId, required this.content});

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
    'content':    content,
  };
}

class MessageModel {
  final int    messageID;
  final int    senderID;
  final int    receiverID;
  final String content;
  final String sentAt;
  final bool   isRead;
  final String? readAt;
  final bool   isMine;

  const MessageModel({
    required this.messageID, required this.senderID,
    required this.receiverID, required this.content,
    required this.sentAt, required this.isRead,
    required this.isMine, this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      MessageModel(
        messageID:  json['messageID']  as int,
        senderID:   json['senderID']   as int,
        receiverID: json['receiverID'] as int,
        content:    json['content']    as String,
        sentAt:     json['sentAt']     as String,
        isRead:     json['isRead']     as bool,
        isMine:     json['isMine']     as bool,
        readAt:     json['readAt']     as String?,
      );
}

class ConversationModel {
  final int    userId;
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final int    unreadCount;
  final bool   isOnline;

  const ConversationModel({
    required this.userId, required this.name,
    required this.lastMessage, required this.lastMessageTime,
    required this.unreadCount, required this.isOnline,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        userId:          json['userId']          as int,
        name:            json['name']            as String,
        lastMessage:     json['lastMessage']     as String,
        lastMessageTime: json['lastMessageTime'] as String,
        unreadCount:     json['unreadCount']     as int,
        isOnline:        json['isOnline']        as bool,
      );
}