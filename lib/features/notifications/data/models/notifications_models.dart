/// ─────────────────────────────────────────────────────────────
/// NOTIFICATIONS MODELS
/// ─────────────────────────────────────────────────────────────

class NotificationModel {
  final int    notificationID;
  final String title;
  final String message;
  final String type;
  final bool   isRead;
  final String createdAt;

  const NotificationModel({
    required this.notificationID, required this.title,
    required this.message, required this.type,
    required this.isRead, required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationID: json['notificationID'] as int,
        title:          json['title']          as String,
        message:        json['message']        as String,
        type:           json['type']           as String,
        isRead:         json['isRead']         as bool,
        createdAt:      json['createdAt']      as String,
      );
}